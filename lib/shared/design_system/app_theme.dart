import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  /// Bundle the Poppins font in pubspec.yaml for pixel-accurate typography.
  /// The app is offline-first, so never load fonts from the network.
  static const String fontFamily = 'Poppins';
  static const List<String> fontFallback = ['Segoe UI', 'Roboto'];

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.brand,
          onSurface: AppColors.ink,
          error: AppColors.error,
        );

    final baseTextTheme = ThemeData.light().textTheme;
    final poppinsTextTheme = baseTextTheme
        .apply(fontFamily: fontFamily, fontFamilyFallback: fontFallback)
        .copyWith(
          headlineSmall: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          titleMedium: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
          bodyLarge: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            color: AppColors.ink,
          ),
          bodyMedium: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            color: AppColors.ink,
          ),
          labelSmall: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.ink,
          ),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallback,
      textTheme: poppinsTextTheme,
      primaryTextTheme: poppinsTextTheme,
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.brand
              : Colors.transparent,
        ),
      ),
    );
  }
}
