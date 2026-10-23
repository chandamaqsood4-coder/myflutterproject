import 'package:flutter/material.dart';

import '../design_system/app_colors.dart';

enum PillTone { success, neutral, warning, danger }

/// Small rounded status label such as "active" or "ACTIVE".
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.tone});

  final String label;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      PillTone.success => (AppColors.successBg, AppColors.successFg),
      PillTone.neutral => (AppColors.chipNeutralBg, AppColors.chipNeutralFg),
      PillTone.warning => (AppColors.warningBg, AppColors.warningFg),
      PillTone.danger => (AppColors.dangerBg, AppColors.dangerFg),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

/// Numeric badge. Green when [highlighted], grey otherwise.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count, this.highlighted = false});

  final int count;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.successBg : AppColors.chipNeutralBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: highlighted ? AppColors.successFg : AppColors.chipNeutralFg,
        ),
      ),
    );
  }
}
