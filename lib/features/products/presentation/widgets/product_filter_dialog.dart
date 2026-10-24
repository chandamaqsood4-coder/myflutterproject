import 'package:flutter/material.dart';

import '../../../../shared/design_system/app_colors.dart';
import '../../domain/product.dart';

// ── Filter model ──────────────────────────────────────────────────────────────

class ProductFilters {
  const ProductFilters({
    this.category,
    this.brand,
    this.stockLevelStatus,
    this.productStatus,
    this.minPriceMinor,
    this.maxPriceMinor,
  });

  final String? category;
  final String? brand;
  final StockLevelFilter? stockLevelStatus;
  final ProductStatus? productStatus;
  final int? minPriceMinor;
  final int? maxPriceMinor;

  bool get hasAny =>
      category != null ||
      brand != null ||
      stockLevelStatus != null ||
      productStatus != null ||
      minPriceMinor != null ||
      maxPriceMinor != null;

  /// Applies this filter to a product list.
  List<Product> apply(List<Product> products) {
    var result = products;

    if (category != null) {
      result = result
          .where(
            (p) => p.categoryName?.toLowerCase() == category!.toLowerCase(),
          )
          .toList();
    }

    if (brand != null) {
      result = result
          .where((p) => p.brandName?.toLowerCase() == brand!.toLowerCase())
          .toList();
    }

    if (stockLevelStatus != null) {
      result = result.where((p) {
        final qty = p.stockQty ?? 0;
        final threshold = p.minQuantityThreshold ?? 0;
        return switch (stockLevelStatus!) {
          StockLevelFilter.inStock => qty > threshold,
          StockLevelFilter.lowStock => qty > 0 && qty <= threshold,
          StockLevelFilter.outOfStock => qty <= 0,
        };
      }).toList();
    }

    if (productStatus != null) {
      result = result.where((p) => p.status == productStatus).toList();
    }

    if (minPriceMinor != null) {
      result = result
          .where((p) => p.sellingPriceMinor >= minPriceMinor!)
          .toList();
    }
    if (maxPriceMinor != null) {
      result = result
          .where((p) => p.sellingPriceMinor <= maxPriceMinor!)
          .toList();
    }

    return result;
  }

  ProductFilters copyWith({
    Object? category = _sentinel,
    Object? brand = _sentinel,
    Object? stockLevelStatus = _sentinel,
    Object? productStatus = _sentinel,
    Object? minPriceMinor = _sentinel,
    Object? maxPriceMinor = _sentinel,
  }) {
    return ProductFilters(
      category: category == _sentinel ? this.category : category as String?,
      brand: brand == _sentinel ? this.brand : brand as String?,
      stockLevelStatus: stockLevelStatus == _sentinel
          ? this.stockLevelStatus
          : stockLevelStatus as StockLevelFilter?,
      productStatus: productStatus == _sentinel
          ? this.productStatus
          : productStatus as ProductStatus?,
      minPriceMinor: minPriceMinor == _sentinel
          ? this.minPriceMinor
          : minPriceMinor as int?,
      maxPriceMinor: maxPriceMinor == _sentinel
          ? this.maxPriceMinor
          : maxPriceMinor as int?,
    );
  }

  static const Object _sentinel = Object();
}

enum StockLevelFilter {
  inStock,
  lowStock,
  outOfStock;

  String get label => switch (this) {
    StockLevelFilter.inStock => 'In Stock',
    StockLevelFilter.lowStock => 'Low Stock',
    StockLevelFilter.outOfStock => 'Out of Stock',
  };
}

// ── Dialog ────────────────────────────────────────────────────────────────────

class ProductFilterDialog extends StatefulWidget {
  const ProductFilterDialog({
    super.key,
    required this.allProducts,
    required this.initial,
    required this.onApply,
  });

  final List<Product> allProducts;
  final ProductFilters initial;
  final ValueChanged<ProductFilters> onApply;

  /// Shows the filter panel as a right-side slide-in drawer.
  static Future<void> show(
    BuildContext context, {
    required List<Product> allProducts,
    required ProductFilters initial,
    required ValueChanged<ProductFilters> onApply,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filter panel',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, animation, _) => ProductFilterDialog(
        allProducts: allProducts,
        initial: initial,
        onApply: onApply,
      ),
      transitionBuilder: (ctx, animation, _, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return SlideTransition(position: slide, child: child);
      },
    );
  }

  @override
  State<ProductFilterDialog> createState() => _ProductFilterDialogState();
}

class _ProductFilterDialogState extends State<ProductFilterDialog> {
  late ProductFilters _filters;

  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = widget.initial;
    if (widget.initial.minPriceMinor != null) {
      _minCtrl.text = (widget.initial.minPriceMinor! / 100).toStringAsFixed(0);
    }
    if (widget.initial.maxPriceMinor != null) {
      _maxCtrl.text = (widget.initial.maxPriceMinor! / 100).toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  List<String> get _categories =>
      widget.allProducts
          .map((p) => p.categoryName)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();

  List<String> get _brands =>
      widget.allProducts
          .map((p) => p.brandName)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();

  int get _matchCount => _filters.apply(widget.allProducts).length;

  void _reset() {
    setState(() {
      _filters = const ProductFilters();
      _minCtrl.clear();
      _maxCtrl.clear();
    });
  }

  void _apply() {
    widget.onApply(_filters);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final matchCount = _matchCount;

    // Right-side panel — fills the full screen height and aligns to the right edge
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: AppColors.surface,
        child: SafeArea(
          child: SizedBox(
            width: 420,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Filter Catalog Products',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: AppColors.textSecondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),

                // ── Body ────────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Category
                        _FilterLabel(label: 'Category'),
                        const SizedBox(height: 8),
                        _FilterDropdown<String>(
                          hint: 'All Categories',
                          value: _filters.category,
                          items: _categories,
                          labelOf: (c) => c,
                          onChanged: (v) => setState(
                            () => _filters = _filters.copyWith(category: v),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Brand
                        _FilterLabel(label: 'Brand'),
                        const SizedBox(height: 8),
                        _FilterDropdown<String>(
                          hint: 'All Brands',
                          value: _filters.brand,
                          items: _brands,
                          labelOf: (b) => b,
                          onChanged: (v) => setState(
                            () => _filters = _filters.copyWith(brand: v),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Stock Level Status
                        _FilterLabel(label: 'Stock Level Status'),
                        const SizedBox(height: 8),
                        _FilterDropdown<StockLevelFilter>(
                          hint: 'All Stock Levels',
                          value: _filters.stockLevelStatus,
                          items: StockLevelFilter.values,
                          labelOf: (s) => s.label,
                          onChanged: (v) => setState(
                            () => _filters = _filters.copyWith(
                              stockLevelStatus: v,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Product Lifecycle Status
                        _FilterLabel(label: 'Product Lifecycle Status'),
                        const SizedBox(height: 8),
                        _FilterDropdown<ProductStatus>(
                          hint: 'All Statuses',
                          value: _filters.productStatus,
                          items: ProductStatus.values,
                          labelOf: (s) => switch (s) {
                            ProductStatus.active =>
                              'Active (Available for sale)',
                            ProductStatus.paused =>
                              'Inactive (Hidden from POS)',
                            ProductStatus.deleted => 'Archived',
                          },
                          onChanged: (v) => setState(
                            () =>
                                _filters = _filters.copyWith(productStatus: v),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Selling Price Range
                        _FilterLabel(label: 'Selling Price Range (PKR)'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _PriceField(
                                controller: _minCtrl,
                                hint: 'Min Rs.',
                                onChanged: (v) {
                                  final n = int.tryParse(v.trim());
                                  setState(
                                    () => _filters = _filters.copyWith(
                                      minPriceMinor: n != null ? n * 100 : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PriceField(
                                controller: _maxCtrl,
                                hint: 'Max Rs.',
                                onChanged: (v) {
                                  final n = int.tryParse(v.trim());
                                  setState(
                                    () => _filters = _filters.copyWith(
                                      maxPriceMinor: n != null ? n * 100 : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1, color: AppColors.border),

                // ── Footer ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: _reset,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.border),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 13,
                          ),
                        ),
                        child: const Text('Reset All'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _apply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 13,
                          ),
                        ),
                        child: Text('Apply Filters ($matchCount matching)'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _FilterLabel extends StatelessWidget {
  const _FilterLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      hint: Text(hint, style: const TextStyle(color: AppColors.hint)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
      ),
      items: [
        DropdownMenuItem<T>(
          value: null,
          child: Text(
            hint,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ...items.map(
          (item) =>
              DropdownMenuItem<T>(value: item, child: Text(labelOf(item))),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hint),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
      ),
    );
  }
}
