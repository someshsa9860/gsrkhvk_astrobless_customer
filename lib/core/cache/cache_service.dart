import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static CacheService? _instance;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _instance = CacheService._();
  }

  CacheService._();
  static CacheService get instance => _instance!;

  Future<void> set(String key, dynamic value, {Duration ttl = const Duration(minutes: 5)}) async {
    final wrapper = {
      'data': value,
      'expiresAt': DateTime.now().add(ttl).millisecondsSinceEpoch,
    };
    await _prefs!.setString(key, jsonEncode(wrapper));
  }

  T? get<T>(String key) {
    final raw = _prefs!.getString(key);
    if (raw == null) return null;
    final wrapper = jsonDecode(raw) as Map<String, dynamic>;
    final expiresAt = wrapper['expiresAt'] as int;
    if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
      _prefs!.remove(key);
      return null;
    }
    return wrapper['data'] as T?;
  }

  Future<void> remove(String key) async => _prefs!.remove(key);

  Future<void> clear() async => _prefs!.clear();
}
