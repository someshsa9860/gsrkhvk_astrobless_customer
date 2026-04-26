import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme_colors.dart';

class AppTheme {
  static ThemeData dark([AppThemeColors? colors]) {
    final c = (colors ?? AppThemeColors.defaults).asDark();
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      extensions: [c],
      colorScheme: ColorScheme.dark(
        primary: c.primary,
        secondary: c.accent,
        surface: c.surfaceDark,
        error: c.error,
      ),
      scaffoldBackgroundColor: c.bgDark,
      appBarTheme: AppBarTheme(
        backgroundColor: c.bgDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: c.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.borderDark),
        ),
      ),
      textTheme: _textTheme(base.textTheme, c),
      inputDecorationTheme: _inputTheme(c.surfaceDark, c.borderDark, c.primary, c.error),
      elevatedButtonTheme: _elevatedButtonTheme(c.primary),
      outlinedButtonTheme: _outlinedButtonTheme(c.primary, c.borderDark),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surfaceDark,
        selectedItemColor: c.accent,
        unselectedItemColor: const Color(0xFF546E7A),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(color: c.borderDark, space: 1),
      chipTheme: _chipTheme(c.surfaceDark, c.borderDark, c.textSecondary),
    );
  }

  static ThemeData light([AppThemeColors? colors]) {
    final c = (colors ?? AppThemeColors.defaultsLight).asLight();
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      extensions: [c],
      colorScheme: ColorScheme.light(
        primary: c.primary,
        secondary: c.accent,
        surface: c.surfaceLight,
        error: c.error,
      ),
      scaffoldBackgroundColor: c.bgLight,
      appBarTheme: AppBarTheme(
        backgroundColor: c.bgLight,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: c.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.borderLight),
        ),
      ),
      textTheme: _textTheme(base.textTheme, c),
      inputDecorationTheme: _inputTheme(c.surfaceLight, c.borderLight, c.primary, c.error),
      elevatedButtonTheme: _elevatedButtonTheme(c.primary),
      outlinedButtonTheme: _outlinedButtonTheme(c.primary, c.borderLight),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surfaceLight,
        selectedItemColor: c.primary,
        unselectedItemColor: const Color(0xFF90A4AE),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(color: c.borderLight, space: 1),
      chipTheme: _chipTheme(c.surfaceLight, c.borderLight, c.textSecondary),
    );
  }

  static TextTheme _textTheme(TextTheme base, AppThemeColors c) =>
      GoogleFonts.interTextTheme(base).copyWith(
        headlineLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: c.textPrimary),
        headlineMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: c.textPrimary),
        headlineSmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: c.textPrimary),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: c.textPrimary),
        titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: c.textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: c.textPrimary),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: c.textSecondary),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: c.textPrimary),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: c.textSecondary),
        labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w400, color: c.textSecondary),
      );

  static InputDecorationTheme _inputTheme(
    Color fill, Color border, Color focus, Color error,
  ) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: focus, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: error)),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF90A4AE), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(Color primary) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(Color primary, Color border) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      );

  static ChipThemeData _chipTheme(Color bg, Color border, Color labelColor) =>
      ChipThemeData(
        backgroundColor: bg,
        side: BorderSide(color: border),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: labelColor),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
}
