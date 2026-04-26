#!/bin/bash
# Run user app against the live server (api.astrobless.app)
flutter run \
  --dart-define=API_BASE_URL=https://api.astrobless.app/v1/customer \
  --dart-define=PUBLIC_API_BASE_URL=https://api.astrobless.app/v1/public \
  --dart-define=WS_BASE_URL=wss://api.astrobless.app \
  --dart-define=IS_DEV=true \
  --dart-define=ENABLE_CERT_PINNING=false \
  "$@"
