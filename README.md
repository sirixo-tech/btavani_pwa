# BT AVANI Backend

Next.js admin dashboard and mobile API for Avani Ganesh Utsav 2026.

## What It Manages

- Payments and reconciliation for UPI QR, Razorpay links and manual collection.
- Seven block payment destinations, organizers, UPI IDs and uploaded QR images.
- CMS content for events, schedule, announcements, gallery, volunteer roles and app settings.
- Participate registrations, volunteer submissions and auction bids from the Flutter app.
- Redis-backed cache for mobile bootstrap reads.

## Local Development

```bash
npm install
npm run dev
```

Open `/admin`. If `ADMIN_PASSWORD` is not set, the local fallback password is `admin123`.

Without `DATABASE_URL`, the dashboard uses seeded in-memory preview data so builds and UI checks still work. With `DATABASE_URL`, the app creates the Postgres tables on first request and inserts seed rows only when IDs do not already exist.

## Mobile API

- `GET /api/mobile/bootstrap` returns active blocks and published CMS data.
- `POST /api/mobile/payments` creates a payment record.
- `POST /api/mobile/registrations` creates a participate registration.
- `POST /api/mobile/volunteers` creates a volunteer submission.
- `POST /api/mobile/bids` creates an auction bid.

Set `MOBILE_API_TOKEN` to require `Authorization: Bearer <token>` on payment writes.

## Railway Deployment

1. Create or open the Railway project that hosts this backend.
2. Add a PostgreSQL service and copy its `DATABASE_URL` into the Next service variables.
3. Add a Redis service and set `REDIS_URL`.
4. Add these variables:

```bash
ADMIN_PASSWORD=your-secure-admin-password
ADMIN_SESSION_SECRET=long-random-secret
ADMIN_SEED_TOKEN=long-random-seed-token
POSTGRES_SSL=true
MOBILE_API_TOKEN=shared-token-for-flutter-writes
```

5. Set the service root to `btavani_backend` if the Railway project points at the repository root.
6. Use build command `npm run build` and start command `npm run start`.
7. After deploy, open `https://your-backend.railway.app/admin`.
8. Optional seed check:

```bash
curl -X POST https://your-backend.railway.app/api/admin/seed \
  -H "Authorization: Bearer $ADMIN_SEED_TOKEN"
```

## Flutter Integration Notes

The Flutter app can replace hardcoded local data with `GET /api/mobile/bootstrap`. Form submissions should POST to the matching mobile endpoint. For QR payments, read each block's `paymentProvider`, `upiId`, `qrImageUrl`, `razorpayKeyId` and `razorpayLink` from the bootstrap response.
