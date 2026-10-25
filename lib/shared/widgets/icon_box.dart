import 'package:flutter/material.dart';

import '../design_system/app_colors.dart';

/// Rounded square with a hairline border holding an icon.
class IconBox extends StatelessWidget {
  const IconBox({
    super.key,
    required this.icon,
    this.color = AppColors.ink,
    this.size = 44,
    this.backgroundColor = AppColors.surface,
  });

  final IconData icon;
  final Color color;
  final double size;
  final Color backgroundColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // color: AppColors.surface,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
