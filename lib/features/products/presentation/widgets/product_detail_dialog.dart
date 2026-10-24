import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/design_system/app_colors.dart';
import '../../domain/product.dart';
import '../product_detail_page.dart';

/// Backward-compatible dialog wrapper for [ProductDetailPage].
class ProductDetailDialog extends ConsumerWidget {
  const ProductDetailDialog({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1280,
          maxHeight: MediaQuery.sizeOf(context).height * 0.94,
        ),
        child: Material(
          color: AppColors.pageBg,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.border),
          ),
          child: ProductDetailPage(
            product: product,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
