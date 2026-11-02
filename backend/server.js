const crypto = require('node:crypto');
const express = require('express');
const admin = require('firebase-admin');
require('dotenv').config();

const CHAPA_API_BASE_URL = 'https://api.chapa.global/v2';
const PLAN_MAP = Object.freeze({
  basic: { amount: 50000, currency: 'ETB', title: 'Basic Plan' },
  pro: { amount: 120000, currency: 'ETB', title: 'Pro Plan' },
  enterprise: { amount: 250000, currency: 'ETB', title: 'Enterprise Plan' },
});

function isTestSecretKey(secretKey) {
  return typeof secretKey === 'string' && secretKey.startsWith('CHASECK_TEST-');
}

function getConfigurationError(secretKey, mode) {
  if (mode !== 'test') {
    return 'This backend is locked to Chapa Test Mode.';
  }
  if (!secretKey) {
    return 'CHAPA_SECRET_KEY is not configured.';
  }
  if (!isTestSecretKey(secretKey)) {
    return 'CHAPA_SECRET_KEY must be a Chapa Test Mode private key.';
  }
  return null;
}

function parseJsonResponse(text) {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function createMerchantReference() {
  return `TM${crypto.randomBytes(9).toString('hex')}`;
}

function safeEqualHex(expected, actual) {
  if (
    typeof actual !== 'string' ||
    !/^[a-f0-9]{64}$/i.test(actual) ||
    !/^[a-f0-9]{64}$/i.test(expected)
  ) {
    return false;
  }
  return crypto.timingSafeEqual(
    Buffer.from(expected, 'hex'),
    Buffer.from(actual, 'hex'),
  );
}

function mapVerifiedStatus(status) {
  switch (status) {
    case 'SUCCESS':
      return 'paid';
    case 'FAILED':
    case 'BLOCKED':
      return 'failed';
    case 'CANCELLED':
      return 'cancelled';
    case 'INCOMPLETE':
      return 'incomplete';
    default:
      return 'pending';
  }
}

function createApp({
  secretKey = process.env.CHAPA_SECRET_KEY,
  mode = process.env.CHAPA_MODE || 'test',
  appBaseUrl = process.env.APP_BASE_URL || '',
  webhookSecret = process.env.CHAPA_WEBHOOK_SECRET || '',
  verifyIdToken = (token) => admin.auth().verifyIdToken(token),
  chapaFetch = globalThis.fetch,
  subscriptions = new Map(),
  idempotency = new Map(),
  processedWebhooks = new Set(),
  makeMerchantReference = createMerchantReference,
} = {}) {
  const app = express();
  const defaultCorsOrigins =
    process.env.NODE_ENV === 'production'
      ? ''
      : 'http://localhost:5000,http://127.0.0.1:5000';
  const allowedCorsOrigins = new Set(
    (process.env.CORS_ORIGINS || defaultCorsOrigins)
      .split(',')
      .map((origin) => origin.trim())
      .filter(Boolean),
  );

  app.use(
    express.json({
      verify(req, res, buffer) {
        req.rawBody = Buffer.from(buffer);
      },
    }),
  );
  app.use((req, res, next) => {
    const origin = req.get('Origin');
    if (!origin) return next();
    if (!allowedCorsOrigins.has(origin)) {
      return res.status(403).json({ message: 'Origin is not allowed.' });
    }

    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Vary', 'Origin');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader(
      'Access-Control-Allow-Headers',
      'Authorization, Content-Type, Idempotency-Key, X-Chapa-Signature',
    );
    if (req.method === 'OPTIONS') return res.sendStatus(204);
    return next();
  });

  function requireUser(req, res, next) {
    const authorization = req.get('Authorization') || '';
    const match = /^Bearer\s+(.+)$/i.exec(authorization);
    if (!match) {
      return res.status(401).json({ message: 'Missing bearer token.' });
    }

    Promise.resolve(verifyIdToken(match[1]))
      .then((user) => {
        req.user = user;
        next();
      })
      .catch(() => {
        res.status(401).json({ message: 'Invalid Firebase session.' });
      });
  }

  async function callChapa(path, options) {
    const response = await chapaFetch(`${CHAPA_API_BASE_URL}${path}`, options);
    const text = await response.text();
    const body = parseJsonResponse(text);
    if (!response.ok) {
      const error = new Error(
        response.status === 401
          ? 'Chapa rejected the configured Test Mode credentials.'
          : `Chapa request failed with HTTP ${response.status}.`,
      );
      error.statusCode = response.status;
      throw error;
    }
    if (!body || typeof body !== 'object') {
      throw new Error('Chapa returned an invalid response.');
    }
    return body;
  }

  function publicAppUrl(path, reference) {
    try {
      const base = new URL(appBaseUrl);
      if (base.protocol !== 'https:') return null;
      base.pathname = `${base.pathname.replace(/\/$/, '')}${path}`;
      if (reference) base.searchParams.set('merchant_reference', reference);
      return base.toString();
    } catch {
      return null;
    }
  }

  async function initializeCheckout({ user, planId, deviceId, idempotencyKey }) {
    const configurationError = getConfigurationError(secretKey, mode);
    if (configurationError) {
      const error = new Error(configurationError);
      error.statusCode = 503;
      throw error;
    }

    const plan = PLAN_MAP[planId];
    const merchantReference = makeMerchantReference();
    if (merchantReference.length > 20) {
      throw new Error('Generated merchant reference exceeds Chapa limits.');
    }

    const payload = {
      amount: plan.amount,
      currency: plan.currency,
      merchant_reference: merchantReference,
      customer: {
        email: user.email || `${user.uid}@example.invalid`,
        first_name: (user.name || 'Tailor').trim().split(/\s+/)[0],
        last_name: (user.name || 'Customer').trim().split(/\s+/).slice(1).join(' ') || 'Customer',
      },
      customization: {
        title: plan.title,
        description: 'TailorMate annual subscription',
      },
      meta: {
        plan_id: planId,
        uid: user.uid,
        device_id: deviceId || 'unknown-device',
      },
    };

    const returnUrl = publicAppUrl('/subscriptions/return', merchantReference);
    const callbackUrl = webhookSecret
      ? publicAppUrl('/subscriptions/webhook')
      : null;
    if (returnUrl) payload.return_url = returnUrl;
    if (callbackUrl) payload.callback_url = callbackUrl;

    const body = await callChapa('/payments/hosted', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${secretKey}`,
        'Content-Type': 'application/json',
        'Idempotency-Key': idempotencyKey,
      },
      body: JSON.stringify(payload),
    });

    if (body.status !== 'success') {
      throw new Error('Chapa did not confirm checkout initialization.');
    }
    const checkoutUrl = body.data?.checkout_url;
    let parsedCheckoutUrl;
    try {
      parsedCheckoutUrl = new URL(checkoutUrl);
    } catch {
      throw new Error('Chapa did not return a valid checkout URL.');
    }
    if (parsedCheckoutUrl.protocol !== 'https:') {
      throw new Error('Chapa returned a non-HTTPS checkout URL.');
    }

    const record = {
      uid: user.uid,
      planId,
      amount: plan.amount,
      currency: plan.currency,
      merchantReference,
      checkoutUrl: parsedCheckoutUrl.toString(),
      status: 'pending',
      createdAt: new Date().toISOString(),
      expiresAt: null,
    };
    subscriptions.set(merchantReference, record);
    return {
      checkout_url: record.checkoutUrl,
      merchant_reference: merchantReference,
      payment_status: record.status,
    };
  }

  async function verifyPayment(record) {
    if (record.status === 'paid') return record;
    const body = await callChapa(
      `/payments/${encodeURIComponent(record.merchantReference)}/verify`,
      {
        method: 'GET',
        headers: {
          Authorization: `Bearer ${secretKey}`,
          Accept: 'application/json',
        },
      },
    );
    if (body.status !== 'success') {
      throw new Error('Chapa could not verify the payment.');
    }
    const payment = body.data;
    if (!payment || typeof payment !== 'object') {
      throw new Error('Chapa returned an invalid verification response.');
    }

    const amount = Number(payment.amount);
    const currency =
      typeof payment.currency === 'string' ? payment.currency.toUpperCase() : '';
    const merchantReference = payment.merchant_reference;
    if (
      !Number.isFinite(amount) ||
      amount !== record.amount ||
      currency !== record.currency ||
      merchantReference !== record.merchantReference
    ) {
      const error = new Error(
        'Verified payment does not match the expected amount, currency, and merchant reference.',
      );
      error.statusCode = 409;
      throw error;
    }

    record.status = mapVerifiedStatus(payment.status);
    if (record.status === 'paid' && !record.expiresAt) {
      const expiresAt = new Date();
      expiresAt.setFullYear(expiresAt.getFullYear() + 1);
      record.expiresAt = expiresAt.toISOString();
    }
    return record;
  }

  app.get('/health', (req, res) => {
    res.json({ status: 'ok', service: 'tailormate-chapa-test-backend' });
  });

  app.post('/subscriptions/checkout', requireUser, async (req, res) => {
    const planId = String(req.body?.plan_id || '').trim().toLowerCase();
    const idempotencyKey = req.get('Idempotency-Key') || '';
    if (!PLAN_MAP[planId]) {
      return res.status(400).json({ message: 'Invalid or missing plan_id.' });
    }
    if (!/^[a-zA-Z0-9._:-]{8,128}$/.test(idempotencyKey)) {
      return res.status(400).json({ message: 'A valid Idempotency-Key is required.' });
    }

    const userKey = `${req.user.uid}:${idempotencyKey}`;
    const existing = idempotency.get(userKey);
    if (existing) {
      if (existing.planId !== planId) {
        return res.status(409).json({
          message: 'Idempotency-Key was already used for a different plan.',
        });
      }
      try {
        return res.json(await existing.promise);
      } catch {
        return res.status(502).json({ message: 'Unable to initialize Chapa checkout.' });
      }
    }

    const operation = initializeCheckout({
      user: req.user,
      planId,
      deviceId: String(req.body?.device_id || '').trim(),
      idempotencyKey,
    });
    idempotency.set(userKey, { planId, promise: operation });
    try {
      return res.json(await operation);
    } catch (error) {
      idempotency.delete(userKey);
      const status = error.statusCode === 503 ? 503 : 502;
      return res.status(status).json({
        message:
          error.statusCode === 503
            ? error.message
            : error.message || 'Unable to initialize Chapa checkout.',
      });
    }
  });

  app.post('/subscriptions/verify', requireUser, async (req, res) => {
    const reference = String(req.body?.merchant_reference || '').trim();
    const record = subscriptions.get(reference);
    if (!record || record.uid !== req.user.uid) {
      return res.status(404).json({ message: 'Payment attempt not found.' });
    }
    try {
      const payment = await verifyPayment(record);
      return res.json({
        active: payment.status === 'paid',
        payment_status: payment.status,
        plan_id: payment.planId,
        merchant_reference: payment.merchantReference,
        expires_at: payment.expiresAt,
      });
    } catch (error) {
      return res.status(error.statusCode || 502).json({
        message: error.message || 'Unable to verify the payment.',
      });
    }
  });

  app.get('/subscriptions/status', requireUser, (req, res) => {
    const record = [...subscriptions.values()].find(
      (payment) =>
        payment.uid === req.user.uid &&
        payment.status === 'paid' &&
        payment.expiresAt &&
        Date.parse(payment.expiresAt) > Date.now(),
    );
    return res.json({
      active: Boolean(record),
      plan_id: record?.planId ?? null,
      expires_at: record?.expiresAt ?? null,
    });
  });

  app.get('/subscriptions/return', (req, res) => {
    res.type('html').send(
      '<!doctype html><html><meta name="viewport" content="width=device-width"><title>TailorMate payment</title><body><h1>Return to TailorMate</h1><p>Payment is not confirmed by this redirect. Return to the app and verify the payment status.</p></body></html>',
    );
  });

  app.post('/subscriptions/webhook', async (req, res) => {
    if (!webhookSecret) {
      return res.status(503).json({ message: 'Webhook verification is not configured.' });
    }
    const signature = req.get('x-chapa-signature') || '';
    const expectedSignature = crypto
      .createHmac('sha256', webhookSecret)
      .update(req.rawBody || Buffer.alloc(0))
      .digest('hex');
    if (!safeEqualHex(expectedSignature, signature)) {
      return res.status(401).json({ message: 'Invalid webhook signature.' });
    }

    const deliveryHash = crypto
      .createHash('sha256')
      .update(req.rawBody || Buffer.alloc(0))
      .digest('hex');
    if (processedWebhooks.has(deliveryHash)) {
      return res.sendStatus(200);
    }

    const event = req.body;
    if (
      event?.webhook_type !== 'payment' ||
      typeof event.event !== 'string' ||
      typeof event.status !== 'string'
    ) {
      return res.status(400).json({ message: 'Invalid payment webhook event.' });
    }
    if (event.mode && event.mode !== 'test') {
      return res.status(400).json({ message: 'Live webhook rejected by Test Mode backend.' });
    }

    const record = subscriptions.get(event.merchant_reference);
    if (!record) {
      return res.status(404).json({ message: 'Payment attempt not found.' });
    }

    try {
      if (event.event === 'payment.success' && event.status === 'success') {
        if (
          Number(event.amount) !== record.amount ||
          String(event.currency || '').toUpperCase() !== record.currency
        ) {
          return res.status(409).json({
            message: 'Webhook amount or currency does not match the payment attempt.',
          });
        }
        await verifyPayment(record);
      } else if (event.status === 'cancelled') {
        record.status = 'cancelled';
      } else if (event.status === 'failed') {
        record.status = 'failed';
      } else if (event.status === 'incomplete') {
        record.status = 'incomplete';
      }
      processedWebhooks.add(deliveryHash);
      return res.sendStatus(200);
    } catch {
      return res.status(502).json({ message: 'Could not verify webhook payment.' });
    }
  });

  app.use((error, req, res, next) => {
    if (res.headersSent) return next(error);
    return res.status(400).json({ message: 'Invalid request.' });
  });
  return app;
}

function startServer() {
  const projectId = process.env.FIREBASE_PROJECT_ID;
  if (!projectId || /your-|placeholder|replace/i.test(projectId)) {
    throw new Error('Set FIREBASE_PROJECT_ID to the Firebase project used by the app.');
  }
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId,
    });
  }

  const port = Number(process.env.PORT || 3000);
  const app = createApp();
  return app.listen(port, () => {
    console.log(`TailorMate Chapa Test Mode backend listening on port ${port}.`);
    console.log('The Chapa private key is read from the backend environment.');
  });
}

if (require.main === module) {
  try {
    startServer();
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}

module.exports = {
  CHAPA_API_BASE_URL,
  PLAN_MAP,
  createApp,
  getConfigurationError,
  isTestSecretKey,
};
