#!/usr/bin/env bash
# Build Flutter web for Vercel (Linux builder).
set -euo pipefail

API_URL="${API_BASE_URL:-https://mrm-rental-manager-backend.vercel.app}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter SDK (stable)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter
  export PATH="/tmp/flutter/bin:${PATH}"
  flutter config --enable-web
  flutter precache --web
fi

flutter --version
flutter pub get
flutter build web --release \
  --dart-define="API_BASE_URL=${API_URL}"

echo "Web build output: build/web"
