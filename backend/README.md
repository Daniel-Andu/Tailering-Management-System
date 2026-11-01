# TailorMate Chapa Test Backend

This backend uses Chapa API v2 Hosted Checkout and is locked to Test Mode. It
verifies payments server-side before activating subscriptions. Automated tests
mock Chapa and never initiate a payment.

See [the Test Mode guide](../docs/CHAPA_BACKEND_GUIDE.md) for setup and manual
checkout instructions.

## Quick start (PowerShell)

```powershell
Copy-Item .env.example .env
# Set CHAPA_SECRET_KEY, FIREBASE_PROJECT_ID and Firebase Admin credentials in .env/the process environment.
npm test
npm start
```

In another terminal:

```powershell
flutter run -d chrome --web-port 5000 --dart-define=SUBSCRIPTION_API_URL=http://localhost:3000
```

Never put `CHAPA_SECRET_KEY` in Flutter or commit `backend/.env`. Use a Test
Mode private key; the server rejects Live Mode keys. Firebase Admin
Application Default Credentials must be configured for Firebase token checks.

## Endpoints

- `GET /health`
- `POST /subscriptions/checkout` — Firebase-authenticated, idempotent v2 checkout
- `POST /subscriptions/verify` — Firebase-authenticated server-side verification
- `GET /subscriptions/status` — Firebase-authenticated active subscription status
- `GET /subscriptions/return` — informational return page; it never confirms payment
- `POST /subscriptions/webhook` — optional signed v2 webhook, requires a public
  HTTPS `APP_BASE_URL` and `CHAPA_WEBHOOK_SECRET`

Checkout and idempotency records are in memory. Do not deploy this version for
Live Mode; durable storage is required.
