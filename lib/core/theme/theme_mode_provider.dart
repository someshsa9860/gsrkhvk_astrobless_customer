import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'user_theme_mode';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_themeModeKey);
      if (saved == 'light') {
        state = ThemeMode.light;
      } else if (saved == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } catch (_) {}
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system';
      await prefs.setString(_themeModeKey, val);
    } catch (_) {}
  }

  void toggle(Brightness currentBrightness) {
    if (state == ThemeMode.system) {
      setMode(currentBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
    } else {
      setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
