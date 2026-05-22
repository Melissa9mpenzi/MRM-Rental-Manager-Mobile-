#!/usr/bin/env bash
# Build Flutter web for Vercel (Linux builder).
set -euo pipefail

API_URL="${API_BASE_URL:-https://mrm-rental-manager-backend.vercel.app}"

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
  --dart-define="API_BASE_URL=${API_URL}"

if [ ! -f build/web/index.html ]; then
  echo "ERROR: build/web/index.html missing — web build failed."
  exit 1
fi

echo "Web build OK: build/web ($(du -sh build/web | cut -f1))"
