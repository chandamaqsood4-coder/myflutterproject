import 'package:flutter/material.dart';

import '../design_system/app_assets.dart';
import '../design_system/app_colors.dart';

/// DukanOS logo. Shows only the icon when [iconOnly] is true.
/// Falls back to a text wordmark (or a store icon) if the asset is missing.
class DukanOsLogo extends StatelessWidget {
  const DukanOsLogo({super.key, this.height = 56, this.iconOnly = false});

  final double height;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final path = iconOnly ? AppAssets.logoIcon : AppAssets.logoHorizontal;
    return Image.asset(
      path,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'DukanOS',
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Logo failed to load ($path): $error');
        if (iconOnly) {
          return Icon(Icons.storefront, size: height, color: AppColors.brand);
        }
        return Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'dukan',
                style: TextStyle(color: AppColors.brandDark),
              ),
              TextSpan(
                text: 'OS',
                style: TextStyle(color: AppColors.brand),
              ),
            ],
          ),
          style: TextStyle(
            fontSize: height * 0.8,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        );
      },
    );
  }
}
