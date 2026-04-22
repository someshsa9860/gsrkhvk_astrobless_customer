import 'dart:io';

class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/v1/customer',
  );
  static const publicApiBaseUrl = String.fromEnvironment(
    'PUBLIC_API_BASE_URL',
    defaultValue: 'http://localhost:3000/v1/public',
  );
  static const wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://localhost:3000',
  );
  static const agoraAppId = String.fromEnvironment('AGORA_APP_ID');
  static const googleMapsKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  static const isDev = bool.fromEnvironment('IS_DEV', defaultValue: true);

  static String get platform => Platform.isIOS ? 'ios' : 'android';
  static const version = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
}
