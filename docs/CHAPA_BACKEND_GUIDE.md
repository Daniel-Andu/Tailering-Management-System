# Chapa Test Mode

The subscription backend uses Chapa API v2 Hosted Checkout. It is locked to
Test Mode; it rejects a missing key, a non-Test key, or `CHAPA_MODE=live`.
Flutter never receives the Chapa private key.

## 1. Configure Firebase and Chapa

From PowerShell:

```powershell
Copy-Item backend\.env.example backend\.env
```

In `backend\.env`, set:

- `CHAPA_MODE=test`
- `CHAPA_SECRET_KEY` to a **Test Mode private key** from Chapa Dashboard →
  Settings → API Keys. Do not copy it into Flutter or commit the file.
- `FIREBASE_PROJECT_ID` to the project ID used by `lib\firebase_options.dart`.
- Firebase Admin Application Default Credentials, for example by setting
  `GOOGLE_APPLICATION_CREDENTIALS` to a local service-account JSON file.

The committed example intentionally contains only the placeholder
`YOUR_TEST_SECRET_KEY`. The repository ignores `backend\.env` and the
recommended service-account file paths.

For local checkout testing, `APP_BASE_URL` can be empty. Chapa will not be sent
an unreachable localhost callback URL. To enable the signed webhook, use a
public HTTPS backend URL and set `CHAPA_WEBHOOK_SECRET` to the webhook secret
configured in Chapa. Webhooks are optional; the authenticated verify endpoint
is used when returning to the app.

## 2. Run mocked tests

```powershell
Set-Location backend
npm test
```

The tests use fake credentials and mocked Chapa HTTP responses. They do not
contact Chapa or initiate payments. They cover Test Mode configuration, 401
initialization failure, v2 request contents, failed/cancelled/successful
verification, idempotency, amount/currency mismatches, Firebase authentication,
and webhook signature/deduplication behavior.

## 3. Run a real Test Mode checkout

Start the backend in one terminal:

```powershell
Set-Location backend
npm start
```

Confirm `http://localhost:3000/health` returns `{"status":"ok",...}`. If the
backend exits, check the Firebase project ID and Admin credentials. A real
Chapa 401 means the private key is invalid or from the wrong Chapa mode; the
backend response does not echo the key.

Start Flutter Web in another terminal:

```powershell
flutter run -d chrome --web-port 5000 --dart-define=SUBSCRIPTION_API_URL=http://localhost:3000
```

Sign in, open **Choose Your Plan**, select a plan, then complete or cancel the
hosted checkout using Chapa's Test Mode. Return to TailorMate and press **I
returned from checkout — verify payment**. The app activates the subscription
only after the backend verifies the v2 payment status, merchant reference,
ETB amount, and currency. Cancelled or pending payments remain inactive.

The API uses `POST /v2/payments/hosted` and
`GET /v2/payments/{merchant_reference}/verify` at `api.chapa.global`. The
backend computes plan prices in integer minor units and does not accept a
client-supplied amount.

This integration covers app subscriptions, not customer order payments. The
order-payment UI now disables Chapa, and the local payment repository rejects
Chapa order entries until an authenticated server-side order checkout and
verification flow exists. Other manually recorded payment methods are
unchanged.

## 4. Limits before production

Subscription attempts and idempotency records are currently in memory. A
backend restart loses them, so this implementation is for Test Mode only and
is not production-ready. Use a durable database and atomic payment-state
transitions before Live Mode.

Official references:

- [Chapa v2 Quick Start](https://docs.chapa.global/docs/v2/getting-started)
- [Hosted Checkout](https://docs.chapa.global/docs/v2/integrations/accept-payment)
- [Verify Payments](https://docs.chapa.global/docs/v2/integrations/verify-payment)
- [Webhook Signature Verification](https://docs.chapa.global/docs/v2/integrations/webhooks)
