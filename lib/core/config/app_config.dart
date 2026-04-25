import 'dart:io';

class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.astrology.qikbill.in/v1/customer',
  );
  static const publicApiBaseUrl = String.fromEnvironment(
    'PUBLIC_API_BASE_URL',
    defaultValue: 'https://api.astrology.qikbill.in/v1/public',
  );
  static const wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'wss://api.astrology.qikbill.in',
  );
  static const agoraAppId = String.fromEnvironment('AGORA_APP_ID');
  static const googleMapsKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  static const isDev = bool.fromEnvironment('IS_DEV', defaultValue: true);

  static String get platform => Platform.isIOS ? 'ios' : 'android';
  static const version = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

  // Client security — all disabled by default; enable per environment via --dart-define
  static const enableCertPinning = bool.fromEnvironment('ENABLE_CERT_PINNING', defaultValue: false);
  static const enableRequestSigning = bool.fromEnvironment('ENABLE_REQUEST_SIGNING', defaultValue: false);
  static const enableAppAttestation = bool.fromEnvironment('ENABLE_APP_ATTESTATION', defaultValue: false);
  // SHA-256 fingerprint of server leaf cert (colon-separated hex, any case)
  // Get with: openssl s_client -connect api.astrology.qikbill.in:443 </dev/null 2>/dev/null | openssl x509 -fingerprint -sha256 -noout
  static const certSha256Fingerprint = String.fromEnvironment('CERT_SHA256_FINGERPRINT', defaultValue: '');
  // Per-audience HMAC secret — must match HMAC_SECRET_CUSTOMER on backend
  static const hmacSecret = String.fromEnvironment('HMAC_SECRET', defaultValue: '');
}
