import 'package:flutter/material.dart';

/// Dynamic brand colors injected into ThemeData.
/// Access via `context.colors` or `Theme.of(context).extension<AppThemeColors>()`.
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.primary,
    required this.accent,
    required this.bgDark,
    required this.cardDark,
    required this.surfaceDark,
    required this.borderDark,
    required this.bgLight,
    required this.cardLight,
    required this.surfaceLight,
    required this.borderLight,
    required this.success,
    required this.error,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });

  final Color primary;
  final Color accent;
  // Dark palette
  final Color bgDark;
  final Color cardDark;
  final Color surfaceDark;
  final Color borderDark;
  // Light palette
  final Color bgLight;
  final Color cardLight;
  final Color surfaceLight;
  final Color borderLight;
  // Status
  final Color success;
  final Color error;
  // Text
  final Color textPrimary;
  final Color textSecondary;
  // Current mode hint (set by AppTheme builders)
  final bool isDark;

  /// Resolved background for the current brightness.
  Color get bg => isDark ? bgDark : bgLight;
  Color get card => isDark ? cardDark : cardLight;
  Color get surface => isDark ? surfaceDark : surfaceLight;
  Color get border => isDark ? borderDark : borderLight;

  /// Default — orange primary, gold accent, system-aware.
  static const defaults = AppThemeColors(
    primary: Color(0xFFFF6D00),   // orange
    accent: Color(0xFFFFB300),    // gold
    bgDark: Color(0xFF0D0B1E),
    cardDark: Color(0xFF1E1B3A),
    surfaceDark: Color(0xFF1A1740),
    borderDark: Color(0xFF2D2A5E),
    bgLight: Color(0xFFFFF8F0),
    cardLight: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFFFF3E0),
    borderLight: Color(0xFFFFE0B2),
    success: Color(0xFF4CAF50),
    error: Color(0xFFF44336),
    textPrimary: Color(0xFFECEFF1),
    textSecondary: Color(0xFFB0BEC5),
    isDark: true,
  );

  static const defaultsLight = AppThemeColors(
    primary: Color(0xFFFF6D00),
    accent: Color(0xFFFFB300),
    bgDark: Color(0xFF0D0B1E),
    cardDark: Color(0xFF1E1B3A),
    surfaceDark: Color(0xFF1A1740),
    borderDark: Color(0xFF2D2A5E),
    bgLight: Color(0xFFFFF8F0),
    cardLight: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFFFF3E0),
    borderLight: Color(0xFFFFE0B2),
    success: Color(0xFF4CAF50),
    error: Color(0xFFF44336),
    textPrimary: Color(0xFF1A1A2E),
    textSecondary: Color(0xFF555577),
    isDark: false,
  );

  factory AppThemeColors.fromConfig(Map<String, dynamic> config) {
    Color hex(String key, Color fallback) {
      final value = config[key];
      if (value is! String) return fallback;
      try {
        return Color(int.parse('FF${value.replaceAll('#', '')}', radix: 16));
      } catch (_) {
        return fallback;
      }
    }

    return AppThemeColors(
      primary: hex('primary', defaults.primary),
      accent: hex('accent', defaults.accent),
      bgDark: hex('bgDark', defaults.bgDark),
      cardDark: hex('cardDark', defaults.cardDark),
      surfaceDark: hex('surfaceDark', defaults.surfaceDark),
      borderDark: hex('borderDark', defaults.borderDark),
      bgLight: hex('bgLight', defaults.bgLight),
      cardLight: hex('cardLight', defaults.cardLight),
      surfaceLight: hex('surfaceLight', defaults.surfaceLight),
      borderLight: hex('borderLight', defaults.borderLight),
      success: hex('success', defaults.success),
      error: hex('error', defaults.error),
      textPrimary: defaults.textPrimary,
      textSecondary: defaults.textSecondary,
      isDark: true,
    );
  }

  AppThemeColors asDark() => copyWith(
        isDark: true,
        textPrimary: const Color(0xFFECEFF1),
        textSecondary: const Color(0xFFB0BEC5),
      );

  AppThemeColors asLight() => copyWith(
        isDark: false,
        textPrimary: const Color(0xFF1A1A2E),
        textSecondary: const Color(0xFF555577),
      );

  @override
  AppThemeColors copyWith({
    Color? primary,
    Color? accent,
    Color? bgDark,
    Color? cardDark,
    Color? surfaceDark,
    Color? borderDark,
    Color? bgLight,
    Color? cardLight,
    Color? surfaceLight,
    Color? borderLight,
    Color? success,
    Color? error,
    Color? textPrimary,
    Color? textSecondary,
    bool? isDark,
  }) {
    return AppThemeColors(
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      bgDark: bgDark ?? this.bgDark,
      cardDark: cardDark ?? this.cardDark,
      surfaceDark: surfaceDark ?? this.surfaceDark,
      borderDark: borderDark ?? this.borderDark,
      bgLight: bgLight ?? this.bgLight,
      cardLight: cardLight ?? this.cardLight,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      borderLight: borderLight ?? this.borderLight,
      success: success ?? this.success,
      error: error ?? this.error,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppThemeColors lerp(AppThemeColors? other, double t) {
    if (other == null) return this;
    return AppThemeColors(
      primary: Color.lerp(primary, other.primary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      bgDark: Color.lerp(bgDark, other.bgDark, t)!,
      cardDark: Color.lerp(cardDark, other.cardDark, t)!,
      surfaceDark: Color.lerp(surfaceDark, other.surfaceDark, t)!,
      borderDark: Color.lerp(borderDark, other.borderDark, t)!,
      bgLight: Color.lerp(bgLight, other.bgLight, t)!,
      cardLight: Color.lerp(cardLight, other.cardLight, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension AppThemeColorsX on BuildContext {
  AppThemeColors get colors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.defaults;
}
