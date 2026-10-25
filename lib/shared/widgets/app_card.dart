import 'package:flutter/material.dart';

import '../design_system/app_colors.dart';

/// White card with a hairline border. Tappable when [onTap] is set.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.selected = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? AppColors.ink : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,

              hoverColor: Colors.transparent,
              child: content,
            ),
    );
  }
}
