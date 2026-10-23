import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  /// Monospace style for SKUs, barcodes and slugs.
  static const TextStyle mono = TextStyle(
    fontFamily: 'Consolas',
    fontFamilyFallback: [
      'DejaVu Sans Mono',
      'Menlo',
      'Courier New',
      'monospace',
    ],
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle tableHeader = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );
}
