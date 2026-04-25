import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Singleton storage service backed by encrypted Hive.
///
/// Provides:
/// - [set] / [get] / [remove] — TTL-aware JSON store (replaces SharedPreferences cache)
/// - [setRaw] / [getRaw] — raw string store (no TTL)
/// - [clear] — nuke a named box
///
/// All boxes are AES-256 encrypted. The encryption key is derived from
/// [flutter_secure_storage] so it survives app restarts but is wiped on
/// device wipe or app uninstall.
///
/// Call [StorageService.init] once in `main()` before `runApp`.
class StorageService {
  StorageService._();

  static StorageService? _instance;
  static StorageService get instance {
    assert(_instance != null, 'StorageService.init() must be called before use');
    return _instance!;
  }

  static const _keyName = 'storage_hive_key';
  static const _cacheBoxName = 'cache';
  static const _rawBoxName = 'raw';

  static const _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  late Box<String> _cacheBox;
  late Box<String> _rawBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Derive (or generate) the AES-256 encryption key stored in secure storage.
    final keyString = await _secureStorage.read(key: _keyName);
    List<int> encryptionKey;

    if (keyString == null) {
      encryptionKey = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _keyName,
        value: base64UrlEncode(encryptionKey),
      );
    } else {
      encryptionKey = base64Url.decode(keyString);
    }

    final cipher = HiveAesCipher(encryptionKey);

    final instance = StorageService._();
    instance._cacheBox = await Hive.openBox<String>(
      _cacheBoxName,
      encryptionCipher: cipher,
    );
    instance._rawBox = await Hive.openBox<String>(
      _rawBoxName,
      encryptionCipher: cipher,
    );

    _instance = instance;
  }

  // ─── TTL-aware cache ─────────────────────────────────────────────────────

  Future<void> set(
    String key,
    dynamic value, {
    Duration ttl = const Duration(minutes: 5),
  }) async {
    final wrapper = jsonEncode({
      'data': value,
      'expiresAt': DateTime.now().add(ttl).millisecondsSinceEpoch,
    });
    await _cacheBox.put(key, wrapper);
  }

  T? get<T>(String key) {
    final raw = _cacheBox.get(key);
    if (raw == null) return null;
    try {
      final wrapper = jsonDecode(raw) as Map<String, dynamic>;
      final expiresAt = wrapper['expiresAt'] as int;
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        _cacheBox.delete(key);
        return null;
      }
      return wrapper['data'] as T?;
    } catch (e) {
      debugPrint('StorageService.get error for key=$key: $e');
      return null;
    }
  }

  Future<void> remove(String key) => _cacheBox.delete(key);

  Future<void> clear() => _cacheBox.clear();

  // ─── Raw (no TTL) ────────────────────────────────────────────────────────

  Future<void> setRaw(String key, String value) => _rawBox.put(key, value);

  String? getRaw(String key) => _rawBox.get(key);

  Future<void> removeRaw(String key) => _rawBox.delete(key);

  Future<void> clearRaw() => _rawBox.clear();

  // ─── Typed helpers ───────────────────────────────────────────────────────

  Future<void> setObject(String key, Map<String, dynamic> value, {Duration ttl = const Duration(minutes: 5)}) =>
      set(key, value, ttl: ttl);

  Map<String, dynamic>? getObject(String key) => get<Map<String, dynamic>>(key);

  Future<void> setBool(String key, bool value, {Duration ttl = const Duration(days: 365)}) =>
      set(key, value, ttl: ttl);

  bool? getBool(String key) => get<bool>(key);
}
