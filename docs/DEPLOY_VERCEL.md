# Mobile web on Vercel

Project: https://mrm-rental-manager-mobile.vercel.app

## API & Sui testnet

The web build points at:

`https://mrm-rental-manager-backend.vercel.app`

| Vercel env | Default | Purpose |
|------------|---------|---------|
| `API_BASE_URL` | production backend URL | REST API |
| `SUI_NETWORK` | `testnet` | Sui portal label + build define |
| `SUI_RPC_URL` | `https://fullnode.testnet.sui.io:443` | Optional explicit RPC |
| `SUI_EXPLORER_BASE` | `https://suiscan.xyz/testnet` | Tx links |

Override with Vercel env vars or `--dart-define=...` on local builds.

## First deploy

1. Connect this repo to Vercel.
2. Root directory: repository root (where `pubspec.yaml` lives).
3. Build uses `scripts/vercel-build-web.sh` (installs Flutter on the builder if needed).
4. Output: `build/web`

### Build log notes

- **`Woah! You appear to be trying to run flutter as root`** — normal on Vercel; safe to ignore if the build continues.
- **`33 packages have newer versions`** — informational only; the build uses `pubspec.lock`.
- If the build fails with a Dart **compile error**, fix it locally with `flutter build web --release` then push.

## Local web build

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://mrm-rental-manager-backend.vercel.app \
  --dart-define=SUI_NETWORK=testnet
```

Android APK (production API + testnet):

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://mrm-rental-manager-backend.vercel.app \
  --dart-define=SUI_NETWORK=testnet
```

Serve `build/web` with any static host.

## Android / iOS

Use **Server settings** in the app to set your PC LAN IP (`http://192.168.x.x:8000`) or the production API URL.
