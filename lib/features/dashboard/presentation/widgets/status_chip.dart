import 'package:flutter/material.dart';

import '../../../../shared/design_system/app_colors.dart';
import '../../domain/dashboard_summary.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final InvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, label) = switch (status) {
      InvoiceStatus.paid => (AppColors.successBg, AppColors.successFg, 'paid'),
      InvoiceStatus.partial => (
        AppColors.warningBg,
        AppColors.warningFg,
        'partial',
      ),
      InvoiceStatus.ledger => (
        AppColors.dangerBg,
        AppColors.dangerFg,
        'ledger',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
