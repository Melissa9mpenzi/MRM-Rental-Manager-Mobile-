# Mobile web on Vercel

Project: https://mrm-rental-manager-mobile.vercel.app

## API

The web build points at:

`https://mrm-rental-manager-backend.vercel.app`

Override with Vercel env `API_BASE_URL` or `--dart-define=API_BASE_URL=...`.

## First deploy

1. Connect this repo to Vercel.
2. Root directory: repository root (where `pubspec.yaml` lives).
3. Build uses `scripts/vercel-build-web.sh` (installs Flutter on the builder if needed).
4. Output: `build/web`

## Local web build

```bash
flutter build web --release --dart-define=API_BASE_URL=https://mrm-rental-manager-backend.vercel.app
```

Serve `build/web` with any static host.

## Android / iOS

Use **Server settings** in the app to set your PC LAN IP (`http://192.168.x.x:8000`) or the production API URL.
