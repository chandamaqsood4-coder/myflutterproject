import 'package:flutter/material.dart';

import '../../../../shared/design_system/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/icon_box.dart';

enum KpiTone { neutral, danger }

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.footerLabel,
    this.iconColor = AppColors.ink,
    this.footerNote,
    this.tone = KpiTone.neutral,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String footerLabel;
  final String? footerNote;
  final KpiTone tone;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconBox(icon: icon, color: iconColor),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: _FooterChip(label: footerLabel, tone: tone),
              ),
              if (footerNote != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    footerNote!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterChip extends StatelessWidget {
  const _FooterChip({required this.label, required this.tone});

  final String label;
  final KpiTone tone;

  @override
  Widget build(BuildContext context) {
    final danger = tone == KpiTone.danger;
    final background = danger ? AppColors.dangerBg : AppColors.chipNeutralBg;
    final foreground = danger ? AppColors.dangerFg : AppColors.chipNeutralFg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            danger ? Icons.trending_down : Icons.remove,
            size: 12,
            color: foreground,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
