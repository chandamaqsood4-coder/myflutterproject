import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/design_system/app_colors.dart';
import '../../../../shared/design_system/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/pills.dart';
import '../../../../shared/widgets/row_action.dart';
import '../../domain/product.dart';

const double _selectWidth = 56;
const double _actionsWidth = 150;
const double _minTableWidth = 880;
const double _rowHeight = 76;

/// Virtualised products table: only visible rows are built, so it stays fast
/// with tens of thousands of products.
class ProductsTable extends StatelessWidget {
  const ProductsTable({
    super.key,
    required this.products,
    required this.selectedIds,
    required this.onToggleRow,
    required this.onToggleAll,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.canEdit,
    required this.canDelete,
  });

  final List<Product> products;
  final Set<int> selectedIds;
  final bool canEdit;
  final bool canDelete;
  final ValueChanged<int> onToggleRow;
  final VoidCallback onToggleAll;
  final ValueChanged<Product> onOpen;
  final ValueChanged<Product> onEdit;
  final ValueChanged<Product> onDelete;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const AppCard(
        child: Center(
          child: Text(
            'No products match your search.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final selectedVisible = products
        .where((p) => selectedIds.contains(p.id))
        .length;
    final bool? headerValue = selectedVisible == 0
        ? false
        : (selectedVisible == products.length ? true : null);

    // The action labels grow with the text scale, so the column widens with
    // them instead of clipping the labels.
    final actionsWidth =
        _actionsWidth * MediaQuery.textScalerOf(context).scale(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final table = AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _HeaderRow(
                checked: headerValue,
                onToggleAll: onToggleAll,
                actionsWidth: actionsWidth,
              ),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemExtent: _rowHeight,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductRow(
                      product: product,
                      selected: selectedIds.contains(product.id),
                      onToggle: () => onToggleRow(product.id),
                      onOpen: () => onOpen(product),
                      onEdit: () => onEdit(product),
                      onDelete: () => onDelete(product),
                      canEdit: canEdit,
                      canDelete: canDelete,
                      actionsWidth: actionsWidth,
                    );
                  },
                ),
              ),
            ],
          ),
        );

        if (constraints.maxWidth >= _minTableWidth) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: _minTableWidth,
            height: constraints.maxHeight,
            child: table,
          ),
        );
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.checked,
    required this.onToggleAll,
    required this.actionsWidth,
  });

  final bool? checked;
  final VoidCallback onToggleAll;
  final double actionsWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          SizedBox(
            width: _selectWidth,
            child: Center(
              child: Checkbox(
                value: checked,
                tristate: true,
                onChanged: (_) => onToggleAll(),
              ),
            ),
          ),
          const Expanded(
            flex: 5,
            child: Text('Product Details', style: AppTextStyles.tableHeader),
          ),
          const Expanded(
            flex: 3,
            child: Text('Category / Brand', style: AppTextStyles.tableHeader),
          ),
          const Expanded(
            flex: 2,
            child: Text('Stock', style: AppTextStyles.tableHeader),
          ),
          const Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(right: 24),
              child: Text(
                'Selling Price',
                textAlign: TextAlign.right,
                style: AppTextStyles.tableHeader,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text('Status', style: AppTextStyles.tableHeader),
          ),
          SizedBox(
            width: actionsWidth,
            child: Center(
              child: Text('Actions', style: AppTextStyles.tableHeader),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.selected,
    required this.onToggle,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.canEdit,
    required this.canDelete,
    required this.actionsWidth,
  });

  final Product product;
  final bool canEdit;
  final bool canDelete;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final double actionsWidth;

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

  @override
  Widget build(BuildContext context) {
    final stock = product.stockQty;
    final stockColor = stock == null
        ? AppColors.textSecondary
        : (stock <= 0 ? AppColors.accentAmber : AppColors.successFg);
    final stockText = stock == null
        ? '—'
        : '${stock.toString()} ${product.unit}';
    final identifiers = product.barcode == null
        ? 'SKU: ${product.sku}'
        : 'SKU: ${product.sku} · Barcode: ${product.barcode}';

    return InkWell(
      onTap: onOpen,
      hoverColor: AppColors.hoverFill,
      child: Ink(
        color: selected ? AppColors.selectedRow : null,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: _selectWidth,
                child: Center(
                  child: Checkbox(
                    value: selected,
                    onChanged: (_) => onToggle(),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.tileFill,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _initials(product.name),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tileText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: AppColors.hint,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            identifiers,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.mono,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    product.categoryAndBrand,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.ink),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  stockText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: stockColor,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Text(
                    formatPkr(product.sellingPriceMinor),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusPill(
                    label: product.status.name,
                    tone: switch (product.status) {
                      ProductStatus.active => PillTone.success,
                      ProductStatus.paused => PillTone.warning,
                      ProductStatus.deleted => PillTone.danger,
                    },
                  ),
                ),
              ),
              SizedBox(
                width: actionsWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (canEdit)
                      RowAction(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        color: AppColors.brand,
                        tooltip: 'Edit ${product.name}',
                        onTap: onEdit,
                      ),
                    if (canEdit && canDelete) const SizedBox(width: 12),
                    if (canDelete)
                      RowAction(
                        icon: Icons.delete_outline,
                        color: AppColors.error,
                        tooltip: 'Delete ${product.name}',
                        onTap: onDelete,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
