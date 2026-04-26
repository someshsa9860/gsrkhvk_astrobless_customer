import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF5C6BC0);       // indigo-400
  static const primaryDark = Color(0xFF3949AB);   // indigo-600
  static const accent = Color(0xFFFFB300);        // amber
  static const accentLight = Color(0xFFFFE082);   // amber-200

  static const bgDark = Color(0xFF0D0B1E);
  static const surfaceDark = Color(0xFF1A1740);
  static const cardDark = Color(0xFF1E1B3A);
  static const borderDark = Color(0xFF2D2A5E);
  static const inputDark = Color(0xFF1A1835);

  static const bgLight = Color(0xFFF5F5FF);
  static const surfaceLight = Color(0xFFFFFFFF);

  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);

  static const textPrimary = Color(0xFFECEFF1);
  static const textSecondary = Color(0xFFB0BEC5);
  static const textDisabled = Color(0xFF546E7A);

  // Chat bubbles
  static const bubbleSent = Color(0xFF3949AB);    // indigo-600 — customer's own messages
  static const bubbleReceived = Color(0xFF1E1B38); // card dark — astrologer messages

  static const List<Color> brandGradient = [Color(0xFF3949AB), Color(0xFF7C4DFF)];
  static const gradientStart = Color(0xFF5C6BC0);
  static const gradientEnd = Color(0xFF9C27B0);
}
