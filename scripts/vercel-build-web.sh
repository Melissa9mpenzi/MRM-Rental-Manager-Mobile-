#!/usr/bin/env bash
# Build Flutter web for Vercel (Linux builder).
set -euo pipefail

API_URL="${API_BASE_URL:-https://mrm-rental-manager-backend.vercel.app}"
SUI_NET="${SUI_NETWORK:-testnet}"
SUI_RPC="${SUI_RPC_URL:-https://fullnode.testnet.sui.io:443}"
SUI_EXPLORER="${SUI_EXPLORER_BASE:-https://suiscan.xyz/testnet}"

# Vercel runs as root — Flutter prints a warning but the build still works.
export CI=true
export HOME="${HOME:-/tmp/flutter-home}"
mkdir -p "${HOME}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter SDK (stable)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter
  export PATH="/tmp/flutter/bin:${PATH}"
  flutter config --enable-web --no-analytics
  flutter precache --web
fi

flutter --version
# Use pubspec.lock — do not upgrade packages during CI.
flutter pub get
flutter build web --release \
  --dart-define="API_BASE_URL=${API_URL}" \
  --dart-define="SUI_NETWORK=${SUI_NET}" \
  --dart-define="SUI_RPC_URL=${SUI_RPC}" \
  --dart-define="SUI_EXPLORER_BASE=${SUI_EXPLORER}"

if [ ! -f build/web/index.html ]; then
  echo "ERROR: build/web/index.html missing — web build failed."
  exit 1
fi

echo "Web build OK: build/web ($(du -sh build/web | cut -f1))"
