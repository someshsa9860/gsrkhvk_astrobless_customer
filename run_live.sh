#!/bin/bash
# Run user app against the live server (api.astrology.qikbill.in)
flutter run \
  --dart-define=API_BASE_URL=https://api.astrology.qikbill.in/v1/customer \
  --dart-define=PUBLIC_API_BASE_URL=https://api.astrology.qikbill.in/v1/public \
  --dart-define=WS_BASE_URL=wss://api.astrology.qikbill.in \
  --dart-define=IS_DEV=true \
  --dart-define=ENABLE_CERT_PINNING=false \
  "$@"
