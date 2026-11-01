const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const http = require('node:http');
const { after, before, beforeEach, test } = require('node:test');
const {
  CHAPA_API_BASE_URL,
  PLAN_MAP,
  createApp,
  getConfigurationError,
  isTestSecretKey,
} = require('../server');

const TEST_KEY = 'CHASECK_TEST-mocked-key';
const TEST_TOKEN = 'firebase-test-token';

let server;
let baseUrl;
let subscriptions;
let idempotency;
let processedWebhooks;
let chapaRequests;
let chapaFetch;
let referenceSequence;

function jsonResponse(status, body) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

function successfulInitializationResponse(checkoutUrl = 'https://checkout.chapa.global/test') {
  return jsonResponse(201, {
    status: 'success',
    data: { checkout_url: checkoutUrl },
  });
}

function verifiedResponse(reference, changes = {}) {
  return jsonResponse(200, {
    status: 'success',
    data: {
      status: 'SUCCESS',
      amount: PLAN_MAP.basic.amount,
      currency: 'ETB',
      merchant_reference: reference,
      ...changes,
    },
  });
}

async function request(path, { method = 'GET', token = TEST_TOKEN, headers = {}, body } = {}) {
  const requestHeaders = { ...headers };
  if (token) requestHeaders.Authorization = `Bearer ${token}`;
  if (body !== undefined) requestHeaders['Content-Type'] = 'application/json';
  return fetch(`${baseUrl}${path}`, {
    method,
    headers: requestHeaders,
    body: body === undefined ? undefined : JSON.stringify(body),
  });
}

before(async () => {
  subscriptions = new Map();
  idempotency = new Map();
  processedWebhooks = new Set();
  chapaRequests = [];
  referenceSequence = 0;
  server = http.createServer(
    createApp({
      secretKey: TEST_KEY,
      mode: 'test',
      verifyIdToken: async (token) => {
        if (token !== TEST_TOKEN) throw new Error('Invalid token');
        return { uid: 'user-test-1', email: 'tailor@example.test', name: 'Test Tailor' };
      },
      chapaFetch: (...args) => chapaFetch(...args),
      subscriptions,
      idempotency,
      processedWebhooks,
      makeMerchantReference: () =>
        `TM${String(++referenceSequence).padStart(18, '0')}`,
      webhookSecret: 'mock-webhook-secret',
    }),
  );
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

beforeEach(() => {
  subscriptions.clear();
  idempotency.clear();
  processedWebhooks.clear();
  chapaRequests = [];
  referenceSequence = 0;
  chapaFetch = async (url, options) => {
    chapaRequests.push({ url, options });
    if (url.endsWith('/payments/hosted')) {
      return successfulInitializationResponse();
    }
    return jsonResponse(500, { status: 'error' });
  };
});

after(async () => {
  if (server) await new Promise((resolve) => server.close(resolve));
});

async function createBasicCheckout(key = 'retry-key-0001') {
  const response = await request('/subscriptions/checkout', {
    method: 'POST',
    headers: { 'Idempotency-Key': key },
    body: { plan_id: 'basic', device_id: 'test-device' },
  });
  assert.equal(response.status, 200);
  return response.json();
}

test('accepts a Test Mode key without making any Chapa network call during the test', () => {
  assert.equal(isTestSecretKey(TEST_KEY), true);
  assert.equal(isTestSecretKey('CHASECK_LIVE-mocked-key'), false);
  assert.equal(getConfigurationError(TEST_KEY, 'test'), null);
});

test('rejects a missing or Live Mode key before calling Chapa', async () => {
  assert.match(getConfigurationError('', 'test'), /not configured/);
  assert.match(
    getConfigurationError('CHASECK_LIVE-mocked-key', 'test'),
    /Test Mode private key/,
  );
  assert.match(getConfigurationError(TEST_KEY, 'live'), /locked to Chapa Test Mode/);

  const app = createApp({
    secretKey: 'CHASECK_LIVE-mocked-key',
    mode: 'test',
    verifyIdToken: async () => ({ uid: 'user-test-1' }),
    chapaFetch: async () => {
      throw new Error('Chapa must not be called for a rejected key');
    },
  });
  const isolated = http.createServer(app);
  await new Promise((resolve) => isolated.listen(0, '127.0.0.1', resolve));
  try {
    const response = await fetch(
      `http://127.0.0.1:${isolated.address().port}/subscriptions/checkout`,
      {
        method: 'POST',
        headers: {
          Authorization: 'Bearer test',
          'Content-Type': 'application/json',
          'Idempotency-Key': 'invalid-key-0001',
        },
        body: JSON.stringify({ plan_id: 'basic' }),
      },
    );
    assert.equal(response.status, 503);
  } finally {
    await new Promise((resolve) => isolated.close(resolve));
  }
});

test('initializes hosted checkout with the v2 endpoint, server amount, and unique reference', async () => {
  chapaRequests = [];
  const result = await createBasicCheckout('init-success-0001');
  const call = chapaRequests.find((item) => item.url.endsWith('/payments/hosted'));
  const payload = JSON.parse(call.options.body);

  assert.equal(call.url, `${CHAPA_API_BASE_URL}/payments/hosted`);
  assert.equal(call.options.method, 'POST');
  assert.equal(call.options.headers.Authorization, `Bearer ${TEST_KEY}`);
  assert.equal(call.options.headers['Idempotency-Key'], 'init-success-0001');
  assert.equal(payload.amount, 50000);
  assert.equal(payload.currency, 'ETB');
  assert.equal(payload.merchant_reference, result.merchant_reference);
  assert.equal(payload.merchant_reference.length, 20);
  assert.equal(result.checkout_url, 'https://checkout.chapa.global/test');
});

test('returns a safe error when Chapa rejects the Test Mode key with HTTP 401', async () => {
  chapaFetch = async () => jsonResponse(401, { message: 'Unauthorized' });
  const response = await request('/subscriptions/checkout', {
    method: 'POST',
    headers: { 'Idempotency-Key': 'init-failure-0001' },
    body: { plan_id: 'basic' },
  });
  const body = await response.json();

  assert.equal(response.status, 502);
  assert.match(body.message, /rejected the configured Test Mode credentials/);
  assert.doesNotMatch(body.message, /mocked-key/);
  chapaFetch = async (url, options) => {
    chapaRequests.push({ url, options });
    return successfulInitializationResponse();
  };
});

test('rejects a successful API response without an HTTPS checkout URL', async () => {
  chapaFetch = async () =>
    jsonResponse(201, {
      status: 'success',
      data: { checkout_url: 'http://not-secure.example/checkout' },
    });
  const response = await request('/subscriptions/checkout', {
    method: 'POST',
    headers: { 'Idempotency-Key': 'invalid-url-0001' },
    body: { plan_id: 'basic' },
  });
  assert.equal(response.status, 502);
  assert.match((await response.json()).message, /non-HTTPS checkout URL/);
});

test('does not activate a cancelled checkout', async () => {
  const checkout = await createBasicCheckout('cancel-test-0001');
  chapaFetch = async (url) =>
    url.includes('/verify')
      ? verifiedResponse(checkout.merchant_reference, { status: 'CANCELLED' })
      : successfulInitializationResponse();
  const response = await request('/subscriptions/verify', {
    method: 'POST',
    body: { merchant_reference: checkout.merchant_reference },
  });
  const result = await response.json();

  assert.equal(response.status, 200);
  assert.equal(result.active, false);
  assert.equal(result.payment_status, 'cancelled');
  chapaFetch = async (url, options) => {
    chapaRequests.push({ url, options });
    return successfulInitializationResponse();
  };
});

test('activates only a successful verified transaction matching reference, amount, and currency', async () => {
  const checkout = await createBasicCheckout('verify-success-0001');
  chapaFetch = async (url, options) => {
    chapaRequests.push({ url, options });
    return verifiedResponse(checkout.merchant_reference);
  };
  const response = await request('/subscriptions/verify', {
    method: 'POST',
    body: { merchant_reference: checkout.merchant_reference },
  });
  const result = await response.json();
  const statusResponse = await request('/subscriptions/status');
  const status = await statusResponse.json();

  assert.equal(response.status, 200);
  assert.equal(result.active, true);
  assert.equal(result.payment_status, 'paid');
  const verificationRequest = chapaRequests.find((call) =>
    call.url.includes('/verify'),
  );
  assert.equal(
    verificationRequest.url,
    `${CHAPA_API_BASE_URL}/payments/${encodeURIComponent(checkout.merchant_reference)}/verify`,
  );
  assert.equal(
    verificationRequest.options.headers.Authorization,
    `Bearer ${TEST_KEY}`,
  );
  assert.equal(status.active, true);
  assert.equal(status.plan_id, 'basic');
});

test('keeps failed transactions unpaid', async () => {
  const checkout = await createBasicCheckout('verify-failed-0001');
  chapaFetch = async () =>
    verifiedResponse(checkout.merchant_reference, { status: 'FAILED' });
  const response = await request('/subscriptions/verify', {
    method: 'POST',
    body: { merchant_reference: checkout.merchant_reference },
  });
  const result = await response.json();

  assert.equal(response.status, 200);
  assert.equal(result.active, false);
  assert.equal(result.payment_status, 'failed');
});

test('retries with the same idempotency key reuse one checkout attempt', async () => {
  chapaRequests = [];
  const first = await createBasicCheckout('duplicate-attempt-01');
  const second = await createBasicCheckout('duplicate-attempt-01');
  const checkoutCalls = chapaRequests.filter((call) =>
    call.url.endsWith('/payments/hosted'),
  );
  assert.equal(checkoutCalls.length, 1);
  assert.equal(first.merchant_reference, second.merchant_reference);
  const distinct = await createBasicCheckout('unique-attempt-0001');
  assert.notEqual(first.merchant_reference, distinct.merchant_reference);

  const conflict = await request('/subscriptions/checkout', {
    method: 'POST',
    headers: { 'Idempotency-Key': 'duplicate-attempt-01' },
    body: { plan_id: 'pro' },
  });
  assert.equal(conflict.status, 409);
});

test('rejects verification with the wrong amount or currency', async (t) => {
  for (const [label, change] of [
    ['amount', { amount: PLAN_MAP.basic.amount + 1 }],
    ['currency', { currency: 'USD' }],
    ['reference', { merchant_reference: 'TM000000000000000000' }],
  ]) {
    await t.test(label, async () => {
      const checkout = await createBasicCheckout(`mismatch-${label}-0001`);
      chapaFetch = async () =>
        verifiedResponse(checkout.merchant_reference, change);
      const response = await request('/subscriptions/verify', {
        method: 'POST',
        body: { merchant_reference: checkout.merchant_reference },
      });
      assert.equal(response.status, 409);
      assert.equal(subscriptions.get(checkout.merchant_reference).status, 'pending');
    });
  }
});

test('rejects unsigned webhooks and deduplicates a correctly signed success event', async () => {
  const checkout = await createBasicCheckout('webhook-attempt-01');
  const event = {
    webhook_type: 'payment',
    event: 'payment.success',
    status: 'success',
    mode: 'test',
    amount: String(PLAN_MAP.basic.amount),
    currency: 'ETB',
    merchant_reference: checkout.merchant_reference,
  };
  const rawBody = JSON.stringify(event);
  const signature = crypto
    .createHmac('sha256', 'mock-webhook-secret')
    .update(rawBody)
    .digest('hex');
  const unauthorized = await fetch(`${baseUrl}/subscriptions/webhook`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: rawBody,
  });
  assert.equal(unauthorized.status, 401);

  let verificationCalls = 0;
  chapaFetch = async (url, options) => {
    if (url.includes('/verify')) {
      verificationCalls++;
      return verifiedResponse(checkout.merchant_reference);
    }
    return successfulInitializationResponse();
  };
  const signedRequest = () =>
    fetch(`${baseUrl}/subscriptions/webhook`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-chapa-signature': signature,
      },
      body: rawBody,
    });
  assert.equal((await signedRequest()).status, 200);
  assert.equal((await signedRequest()).status, 200);
  assert.equal(verificationCalls, 1);
  assert.equal(subscriptions.get(checkout.merchant_reference).status, 'paid');
});

test('rejects checkout requests without Firebase authentication', async () => {
  const response = await request('/subscriptions/checkout', {
    method: 'POST',
    token: null,
    headers: { 'Idempotency-Key': 'unauthenticated-01' },
    body: { plan_id: 'basic' },
  });
  assert.equal(response.status, 401);
});
