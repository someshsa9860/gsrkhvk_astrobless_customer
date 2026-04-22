import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'app_theme_colors.dart';

const _cacheKey = 'theme_config_cache';

/// Fetches the current brand theme from the public API.
/// Falls back to locally-cached config, then to [AppThemeColors.defaults].
final appThemeColorsProvider = FutureProvider<AppThemeColors>((ref) async {
  return _fetchThemeColors();
});

Future<AppThemeColors> _fetchThemeColors() async {
  try {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.publicApiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    final res = await dio.get<Map<String, dynamic>>('/settings/theme');
    final config = (res.data?['data'] as Map<String, dynamic>?) ?? {};
    if (config.isNotEmpty) {
      await _cacheTheme(config);
      return AppThemeColors.fromConfig(config);
    }
  } catch (_) {
    // Network failure — try local cache before returning defaults.
  }

  final cached = await _loadCachedTheme();
  if (cached != null) return AppThemeColors.fromConfig(cached);

  return AppThemeColors.defaults;
}

Future<void> _cacheTheme(Map<String, dynamic> config) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(config));
  } catch (_) {}
}

Future<Map<String, dynamic>?> _loadCachedTheme() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}
