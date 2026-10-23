import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/design_system/app_colors.dart';
import '../../../../shared/design_system/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/pills.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/product.dart';
import '../providers/product_providers.dart';
import 'product_form_dialog.dart';

class ProductDetailDialog extends ConsumerWidget {
  const ProductDetailDialog({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(productDetailProvider(product.id));
    final p = detail.value ?? product;
    final canEdit = ref
        .watch(currentPermissionsProvider)
        .contains('products.update');

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1040,
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        child: Material(
          color: AppColors.pageBg,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(
                product: p,
                loading: detail.isLoading,
                canEdit: canEdit,
                onEdit: () => _edit(context, ref, p),
                onClose: () => Navigator.of(context).pop(),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (detail.hasError) ...[
                            _ErrorNotice(error: detail.error),
                            const SizedBox(height: 16),
                          ],
                          _Sections(product: p),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Product p) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => ProductFormDialog(product: p),
    );
    if (saved != true) return;
    ref.invalidate(productsProvider);
    ref.invalidate(productDetailProvider(p.id));
    if (context.mounted) showMessage(context, 'Product updated.');
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.product,
    required this.loading,
    required this.canEdit,
    required this.onEdit,
    required this.onClose,
  });

  final Product product;
  final bool loading;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              return Row(
                children: [
                  IconButton(
                    tooltip: 'Back to products',
                    onPressed: onClose,
                    icon: const Icon(Icons.arrow_back, size: 20),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'Products',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AppColors.hint,
                          ),
                        ),
                        const Flexible(
                          child: Text(
                            'Product details',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  if (canEdit)
                    compact
                        ? IconButton.outlined(
                            tooltip: 'Edit product',
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                          )
                        : OutlinedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Edit Product'),
                          ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductAvatar(product: product, size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'SKU: ${product.sku}',
                            style: AppTextStyles.mono,
                          ),
                          if (product.categoryAndBrand != '—')
                            Text(
                              product.categoryAndBrand,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          StatusPill(
                            label: product.status.name,
                            tone: switch (product.status) {
                              ProductStatus.active => PillTone.success,
                              ProductStatus.paused => PillTone.warning,
                              ProductStatus.deleted => PillTone.danger,
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sections extends StatelessWidget {
  const _Sections({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ImagesSection(product: product),
            const SizedBox(height: 16),
            _InformationSection(product: product),
            const SizedBox(height: 16),
            _PricingSection(product: product),
          ],
        );
        final right = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StockSection(product: product),
            const SizedBox(height: 16),
            const _SalesInformationSection(),
            const SizedBox(height: 16),
            const _SalesHistorySection(),
          ],
        );

        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: 16), right],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: left),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: right),
          ],
        );
      },
    );
  }
}

class _ImagesSection extends StatelessWidget {
  const _ImagesSection({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;

    return _SectionCard(
      icon: Icons.image_outlined,
      title: 'Product Images',
      subtitle: 'The first image is used as the main product picture across POS and catalog.',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductAvatar(product: product, size: 96),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Primary image',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (hasImage)
                      const StatusPill(label: 'Main', tone: PillTone.success),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.fieldFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    hasImage ? product.imageUrl! : 'No image URL added yet.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasImage ? AppColors.ink : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manage images from Edit Product.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationSection extends StatelessWidget {
  const _InformationSection({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final description = product.description?.trim();

    return _SectionCard(
      icon: Icons.info_outline,
      title: 'Product Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FieldGrid(
            fields: [
              _FieldData('Category', product.categoryName ?? '—'),
              _FieldData('Brand', product.brandName ?? '—'),
              _FieldData('Unit of Sale', product.unit),
              _FieldData('Barcode', product.barcode ?? '—', mono: true),
              _FieldData(
                'Status',
                product.status.name,
                child: StatusPill(
                  label: product.status.name,
                  tone: switch (product.status) {
                    ProductStatus.active => PillTone.success,
                    ProductStatus.paused => PillTone.warning,
                    ProductStatus.deleted => PillTone.danger,
                  },
                ),
              ),
              _FieldData(
                'Low-Stock Threshold',
                product.minQuantityThreshold?.toString() ?? '—',
              ),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 16),
            const _FieldLabel('Description'),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
            ),
          ],
        ],
      ),
    );
  }
}

class _PricingSection extends StatelessWidget {
  const _PricingSection({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final cost = product.purchasePriceMinor;
    final profit = cost == null ? null : product.sellingPriceMinor - cost;
    final margin = (cost == null || cost <= 0) ? null : (profit! / cost) * 100;
    final stockValue = cost == null ? null : cost * (product.stockQty ?? 0);

    return _SectionCard(
      icon: Icons.sell_outlined,
      title: 'Pricing & Profitability',
      child: _StatGrid(
        stats: [
          _StatData('Selling Price', formatPkr(product.sellingPriceMinor)),
          _StatData('Purchase Cost', cost == null ? '—' : formatPkr(cost)),
          _StatData(
            'Profit / Unit',
            profit == null ? '—' : formatPkr(profit),
            tone: profit == null
                ? null
                : (profit >= 0 ? AppColors.brand : AppColors.error),
          ),
          _StatData(
            'Margin',
            margin == null ? '—' : '${margin.toStringAsFixed(1)}%',
            tone: margin == null
                ? null
                : (margin >= 0 ? AppColors.brand : AppColors.error),
          ),
          _StatData(
            'Stock Value',
            stockValue == null ? '—' : formatPkr(stockValue),
          ),
        ],
      ),
    );
  }
}

class _StockSection extends StatelessWidget {
  const _StockSection({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final stock = product.stockQty;

    return _SectionCard(
      icon: Icons.inventory_2_outlined,
      title: 'Stock & Inventory',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                stock == null ? '—' : formatQuantity(stock.toDouble()),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: AppColors.ink,
                ),
              ),
              if (stock != null) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    product.unit,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Text(
            'Current stock on hand',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          _DetailLine(
            label: 'Low-Stock Threshold',
            value: product.minQuantityThreshold?.toString() ?? '—',
            helper: 'Alerts when stock falls at or below this level.',
          ),
          const SizedBox(height: 16),
          const _DetailLine(
            label: 'Stock Status on POS',
            value: 'Auto-synced',
            valueColor: AppColors.brand,
            helper: 'Sold quantities decrement automatically after each sale.',
          ),
        ],
      ),
    );
  }
}

class _SalesInformationSection extends StatelessWidget {
  const _SalesInformationSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      icon: Icons.bar_chart_outlined,
      title: 'Sales Information',
      child: _StatGrid(
        columns: 2,
        stats: [
          _StatData('Units Sold', '—'),
          _StatData('Total Revenue', '—'),
          _StatData('Documents', '—'),
          _StatData('Last Sale', '—'),
        ],
      ),
    );
  }
}

class _SalesHistorySection extends StatelessWidget {
  const _SalesHistorySection();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      icon: Icons.receipt_long_outlined,
      title: 'Sales History',
      child: _EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No sales recorded yet',
        message: 'This product has not appeared on any invoice or quotation. It will track automatically once sold from the POS.',
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionIcon(icon: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _SectionIcon extends StatelessWidget {
  const _SectionIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: AppColors.ink),
    );
  }
}

class _FieldData {
  const _FieldData(this.label, this.value, {this.mono = false, this.child});

  final String label;
  final String value;
  final bool mono;
  final Widget? child;
}

class _FieldGrid extends StatelessWidget {
  const _FieldGrid({required this.fields});

  final List<_FieldData> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 420 ? 2 : 1;
        const gap = 16.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: 18,
          children: [
            for (final field in fields)
              SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(field.label),
                    const SizedBox(height: 5),
                    field.child ??
                        Text(
                          field.value,
                          style: field.mono
                              ? AppTextStyles.mono.copyWith(fontSize: 13)
                              : const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.ink,
                                ),
                        ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
    );
  }
}

class _StatData {
  const _StatData(this.label, this.value, {this.tone});

  final String label;
  final String value;
  final Color? tone;
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats, this.columns});

  final List<_StatData> stats;

  /// Fixed column count. When null it adapts to the available width.
  final int? columns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count =
            columns ??
            (constraints.maxWidth >= 480
                ? 3
                : (constraints.maxWidth >= 300 ? 2 : 1));
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (count - 1)) / count;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final stat in stats)
              SizedBox(
                width: width,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.fieldFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        stat.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: stat.tone ?? AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
    required this.helper,
    this.valueColor,
  });

  final String label;
  final String value;
  final String helper;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          helper,
          style: const TextStyle(
            fontSize: 11,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 26, color: AppColors.hint),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductAvatar extends StatelessWidget {
  const _ProductAvatar({required this.product, required this.size});

  final Product product;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.tileFill,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Text(
        _initials(product.name),
        style: TextStyle(
          fontSize: size * 0.28,
          fontWeight: FontWeight.w700,
          color: AppColors.tileText,
        ),
      ),
    );

    if (url == null || url.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }

  static String _initials(String name) {
    final words = name
        .split(RegExp(r'[^A-Za-z0-9]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      final w = words.first;
      return (w.length > 1 ? w.substring(0, 2) : w).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error is ApiException
                  ? (error as ApiException).message
                  : 'Could not load the latest product details.',
              style: const TextStyle(fontSize: 13, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
