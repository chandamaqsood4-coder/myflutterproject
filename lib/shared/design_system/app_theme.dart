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

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallback,
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
