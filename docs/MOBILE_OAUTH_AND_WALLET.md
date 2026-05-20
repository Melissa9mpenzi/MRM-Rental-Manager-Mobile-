# Mobile ↔ Backend: wallet & OAuth

## Wallet (`GET /api/v1/payments/wallet-summary`)

Returns JSON inside the usual `{ "success": true, "data": ... }` envelope (the Flutter `Dio` client unwraps `data`):

- `total_paid_ugx` — sum of **non-deleted** `Payment` rows visible to the user  
- `payment_count`  
- `by_method` — map of `payment_method` enum string → total UGX  
- `scope` — `"tenant"` | `"owner"` | `"admin"`  

**Tenant:** payments linked to their `Tenant` profile.  
**Landlord / staff:** payments where `owner_id` is the logged-in user.  
**Admin:** all payments on the platform (read-only overview).

The mobile **Wallet** screen uses this for the balance header and builds “payment methods used” chips from `by_method`.

## Google sign-in (`POST /api/v1/auth/firebase`)

Body: `{ "id_token": "<Firebase ID token>" }`  
Response: same shape as email login (`access_token`, `refresh_token`, `user`).

Requirements:

1. Firebase project with Authentication (Google provider) enabled.  
2. Backend `firebase` / `GOOGLE_APPLICATION_CREDENTIALS` configured so `verify_firebase_id_token` works.  
3. Flutter: `flutterfire configure`, then `firebase_core` + `firebase_auth` + `google_sign_in`, initialize before `runApp`, obtain ID token, call `AuthApi.firebaseSignIn`.

The account email **must already exist** in the database (register on web or via email registration first).
