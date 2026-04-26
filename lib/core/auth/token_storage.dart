import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const _accessKey = 'customer_access_token';
  static const _refreshKey = 'customer_refresh_token';
  static const _customerIdKey = 'customer_id';

  static Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  static Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);
  static Future<String?> getCustomerId() => _storage.read(key: _customerIdKey);

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? customerId,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
      if (customerId != null)
        _storage.write(key: _customerIdKey, value: customerId),
    ]);
  }

  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
      _storage.delete(key: _customerIdKey),
    ]);
  }

  static Future<bool> hasTokens() async {
    final token = await _storage.read(key: _accessKey);
    return token != null && token.isNotEmpty;
  }
}
