import 'package:flutter/material.dart';

/// DukanOS palette, sampled from the web app.
abstract final class AppColors {
  // Brand
  static const Color brandDark = Color(0xFF0B3B24);
  static const Color brand = Color(0xFF0B8F4D);

  // Neutrals
  static const Color ink = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color hint = Color(0xFF9CA3AF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color fieldFill = Color(0xFFF4F4F5);
  static const Color hoverFill = Color(0xFFF4F4F5);
  static const Color pageBg = Color(0xFFFAFAF9);
  static const Color selectedRow = Color(0xFFF6F8FA);
  static const Color tileFill = Color(0xFFEEF1F6);
  static const Color tileText = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE5E7EB);
  static const Color chipNeutralBg = Color(0xFFF1F1F2);
  static const Color chipNeutralFg = Color(0xFF374151);

  // Status
  static const Color error = Color(0xFFB42318);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color successFg = Color(0xFF065F46);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningFg = Color(0xFF92400E);
  static const Color dangerBg = Color(0xFFFEE2E2);
  static const Color dangerFg = Color(0xFFB91C1C);

  // Accents
  static const Color accentAmber = Color(0xFFB45309);
}
