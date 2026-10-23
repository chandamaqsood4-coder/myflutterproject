import 'package:flutter/material.dart';

import '../design_system/app_colors.dart';

/// Page title, description and an optional primary action on the right.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  /// Below this width the title, subtitle and action are stacked.
  static const double _wideBreakpoint = 640;

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              letterSpacing: -0.6,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // On narrow windows the action moves below the heading so the title
        // and the subtitle keep the full width instead of being squeezed.
        if (constraints.maxWidth < _wideBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              if (action != null) ...[const SizedBox(height: 12), action!],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heading),
            if (action != null) ...[const SizedBox(width: 16), action!],
          ],
        );
      },
    );
  }
}
