#!/bin/bash
# Run user app against localhost:3000
# iOS Simulator: use 127.0.0.1 (not 10.0.2.2 — that's Android emulator)
# Android Emulator: change 127.0.0.1 to 10.0.2.2
flutter run \
  --dart-define=API_BASE_URL=http://127.0.0.1:3008/v1/customer \
  --dart-define=PUBLIC_API_BASE_URL=http://127.0.0.1:3008/v1/public \
  --dart-define=WS_BASE_URL=ws://127.0.0.1:3008 \
  --dart-define=IS_DEV=true \
  --dart-define=ENABLE_CERT_PINNING=false \
  "$@"
