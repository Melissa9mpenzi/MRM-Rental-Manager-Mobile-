# MRM Rental Manager — Mobile App

Flutter application for **RentDirect UG**, sharing the same backend as the web frontend. Targets **Android**, **iOS**, and **Flutter web** (deployed on Vercel).

| Environment | URL |
|-------------|-----|
| **Web (production)** | https://mrm-rental-manager-mobile.vercel.app |
| **Backend API** | https://mrm-rental-manager-backend.vercel.app |
| **Web frontend** | https://mrm-rental-manager-frontend-pink.vercel.app |

**Related repos**

| App | Repo |
|-----|------|
| Backend API | [MRM-Rental-Manager-Backend-](https://github.com/Melissa9mpenzi/MRM-Rental-Manager-Backend-) |
| React web app | [MRM-Rental-Manager-Frontend-](https://github.com/Melissa9mpenzi/MRM-Rental-Manager-Frontend-) |

---

## What this app does

The mobile client mirrors core RentDirect UG flows:

- **Authentication** — login, registration, secure token storage
- **Marketplace** — browse and view property listings
- **Tenant & landlord tools** — dashboards, payments, profile
- **Configurable API URL** — for local dev on emulator or physical device

On **web builds**, the app defaults to the production Vercel backend. On **Android/iOS**, you can point at your local machine during development.

---

## Tech stack

- **Flutter 3** (Dart SDK ≥ 3.0)
- **Riverpod** for state management
- **Go Router** for navigation
- **Dio** for HTTP
- **flutter_secure_storage** for tokens
- **Firebase Auth** + Google / Apple sign-in (optional)
- **Vercel** for Flutter web deployment

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Android Studio and/or Xcode for device builds
- Backend API (local or production)

Verify setup:

```bash
flutter doctor
```

---

## Local development

### 1. Install dependencies

```bash
cd MRM-Rental-Manager-Mobile-
flutter pub get
```

### 2. Choose API target

Default behavior (`lib/core/config/api_url_store.dart`):

| Platform | Default API |
|----------|-------------|
| **Web** | `https://mrm-rental-manager-backend.vercel.app` |
| **Android emulator** | `http://10.0.2.2:8000` (maps to host `localhost`) |
| **iOS simulator / desktop** | `http://localhost:8000` |
| **Physical phone** | Set your PC's LAN IP in app **Server settings** |

Override at build time:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

### 3. Run

```bash
# Chrome (web)
flutter run -d chrome

# Android emulator
flutter run -d android

# iOS simulator (macOS only)
flutter run -d ios
```

---

## Building

### Web (local)

```bash
flutter build web --release
```

Output: `build/web/`

### Android APK

```bash
flutter build apk --release
```

### iOS (macOS + Xcode required)

```bash
flutter build ios --release
```

---

## Deploying web to Vercel

The repo includes `vercel.json` and `scripts/vercel-build-web.sh`.

1. Connect this repo to Vercel.
2. Build uses the shell script (Flutter web release build).
3. Output directory: `build/web`
4. First deploy may take 10–15 minutes while Flutter is installed.

Production URL: https://mrm-rental-manager-mobile.vercel.app

---

## Branding & favicon

Browser tab and PWA icons use the **MRM / RentDirect** logo, generated from the same asset as the web frontend:

- `web/favicon.png`
- `web/icons/Icon-192.png`, `Icon-512.png`, maskable variants
- `web/manifest.json` — app name **RentDirect UG**
- `windows/runner/resources/app_icon.ico` — Windows desktop builds

After updating the logo source, regenerate these PNG/ICO files and rebuild.

---

## Project structure

```
lib/
  core/
    config/         # API URL, theme, constants
    theme/          # Colors, typography (matches web design system)
    widgets/        # Shared UI (BrandLogo, etc.)
  features/         # Feature modules (auth, marketplace, tenant, …)
  main.dart         # App entry
assets/
  images/           # Listing photos, hero images
  icons/            # Payment method SVGs, social login icons
web/
  index.html        # Web shell, favicon, manifest
  icons/            # PWA icons
scripts/
  vercel-build-web.sh
```

---

## Firebase (optional)

For Google / Apple sign-in on mobile:

1. Create a Firebase project and add Android, iOS, and Web apps.
2. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
3. Configure web client ID in `web/index.html` if using Google Sign-In on web.

---

## Testing

```bash
flutter test
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Cannot reach API on phone | Use your PC's LAN IP, not `localhost`; ensure backend listens on `0.0.0.0:8000` |
| Android emulator can't hit localhost | App auto-rewrites to `10.0.2.2` — start backend on port 8000 |
| Web shows wrong API | Rebuild with `--dart-define=API_BASE_URL=...` or clear site data |
| Vercel build slow/fails | Check build logs; ensure Flutter install step in `vercel-build-web.sh` completes |

---

## License

Private — MRM Rental Manager / RentDirect UG.
