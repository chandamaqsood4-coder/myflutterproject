import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/design_system/app_colors.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../shared/widgets/pill_buttons.dart';
import '../../../shared/widgets/search_field.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../domain/product.dart';
import 'product_detail_page.dart';
import 'product_edit_page.dart';
import 'providers/product_providers.dart';
import 'widgets/product_filter_dialog.dart';
import 'widgets/product_print_dialog.dart';
import 'widgets/products_table.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  static const Duration _searchDelay = Duration(milliseconds: 300);

  String _query = '';
  Timer? _debounce;
  ProductPage? _lastPage;
  final Set<int> _selected = <int>{};
  ProductFilters _filters = const ProductFilters();

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDelay, () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _toggleRow(int id) => setState(() {
    if (!_selected.remove(id)) _selected.add(id);
  });

  void _toggleAll(List<Product> visible) => setState(() {
    final ids = visible.map((p) => p.id).toList();
    final allSelected = ids.isNotEmpty && ids.every(_selected.contains);
    if (allSelected) {
      _selected.removeAll(ids);
    } else {
      _selected.addAll(ids);
    }
  });

  void _openForm([Product? product]) {
    ref
        .read(editingProductProvider.notifier)
        .edit(
          product ??
              const Product(
                id: 0,
                name: '',
                sku: '',
                unit: 'pc',
                sellingPriceMinor: 0,
                status: ProductStatus.active,
              ),
        );
  }

  void _openDetail(Product product) {
    ref.read(selectedProductDetailProvider.notifier).state = product;
  }

  Future<void> _delete(Product product) async {
    final confirmed = await confirmDelete(
      context,
      title: 'Delete this product?',
      message:
          'This permanently removes the product from the catalog. '
          'Historical invoices and quotations will still show its name, but '
          'the product can no longer be sold. This cannot be undone.',
      confirmLabel: 'Delete Product',
    );
    if (!confirmed || !mounted) return;

    try {
      await ref.read(productRepositoryProvider).deleteProduct(product.id);
      if (!mounted) return;
      setState(() => _selected.remove(product.id));
      ref.invalidate(productsProvider);
      ref.invalidate(productDetailProvider);
      showMessage(context, 'Deleted ${product.name}.');
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editingProduct = ref.watch(editingProductProvider);
    if (editingProduct != null) {
      return ProductEditPage(
        product: editingProduct.id != 0 ? editingProduct : null,
        onBack: () => ref.read(editingProductProvider.notifier).clear(),
      );
    }

    final selectedProduct = ref.watch(selectedProductDetailProvider);
    if (selectedProduct != null) {
      return ProductDetailPage(
        product: selectedProduct,
        onBack: () =>
            ref.read(selectedProductDetailProvider.notifier).state = null,
      );
    }

    final permissions = ref.watch(currentPermissionsProvider);
    final canCreate = permissions.contains('products.create');
    final canEdit = permissions.contains('products.update');
    final canDelete = permissions.contains('products.delete');

    final result = ref.watch(productsProvider(_query));
    if (result is AsyncData<ProductPage>) _lastPage = result.value;
    final page = _lastPage;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Products & Stock',
                subtitle: 'Manage appliance items, dynamic specifications, barcode identifiers, and stock levels.',
                action: canCreate
                    ? PrimaryPillButton(
                        icon: Icons.add,
                        label: 'Add Product',
                        onPressed: () => _openForm(),
                      )
                    : null,
              ),
              const SizedBox(height: 24),
              _Toolbar(
                onSearch: _onSearchChanged,
                onPrint: () {
                  final products = _lastPage?.items ?? const [];
                  final displayed = _filters.apply(products);
                  ProductPrintDialog.show(context, products: displayed);
                },
                onFilters: () {
                  final allProducts = _lastPage?.items ?? const [];
                  ProductFilterDialog.show(
                    context,
                    allProducts: allProducts,
                    initial: _filters,
                    onApply: (f) => setState(() => _filters = f),
                  );
                },
                activeFilterCount: _filters.hasAny
                    ? _filters.apply(_lastPage?.items ?? []).length
                    : null,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: page == null
                    ? (result is AsyncError
                          ? _LoadError(
                              message: _messageOf(result.error),
                              onRetry: () =>
                                  ref.invalidate(productsProvider(_query)),
                            )
                          : const Center(child: CircularProgressIndicator()))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CountLine(
                            shown: _filters.apply(page.items).length,
                            total: page.total,
                            loading: result.isLoading,
                            filtered: _filters.hasAny,
                          ),
                          if (result is AsyncError) ...[
                            const SizedBox(height: 8),
                            _ErrorBanner(
                              message: _messageOf(result.error),
                              onRetry: () =>
                                  ref.invalidate(productsProvider(_query)),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Expanded(
                            child: ProductsTable(
                              products: _filters.apply(page.items),
                              selectedIds: _selected,
                              canEdit: canEdit,
                              canDelete: canDelete,
                              onToggleRow: _toggleRow,
                              onToggleAll: () =>
                                  _toggleAll(_filters.apply(page.items)),
                              onOpen: _openDetail,
                              onEdit: canEdit ? _openForm : (_) {},
                              onDelete: _delete,
                            ),
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

  static String _messageOf(Object? error) =>
      error is ApiException ? error.message : 'Could not load products.';
}

class _CountLine extends StatelessWidget {
  const _CountLine({
    required this.shown,
    required this.total,
    required this.loading,
    this.filtered = false,
  });

  final int shown;
  final int total;
  final bool loading;
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    const bold = TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink);
    return Row(
      children: [
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            children: [
              const TextSpan(text: 'Showing '),
              TextSpan(text: '$shown', style: bold),
              if (filtered) ...[
                const TextSpan(text: ' filtered of '),
                TextSpan(text: '$total', style: bold),
              ] else ...[
                const TextSpan(text: ' of '),
                TextSpan(text: '$total', style: bold),
              ],
              const TextSpan(text: ' products'),
            ],
          ),
        ),
        if (loading) ...[
          const SizedBox(width: 12),
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.onSearch,
    required this.onPrint,
    required this.onFilters,
    this.activeFilterCount,
  });

  final ValueChanged<String> onSearch;
  final VoidCallback onPrint;
  final VoidCallback onFilters;
  final int? activeFilterCount;

  @override
  Widget build(BuildContext context) {
    final search = SearchField(
      hint: 'Search products by name, SKU, or barcode...',
      onChanged: onSearch,
    );

    final filterLabel = activeFilterCount != null
        ? 'Filters ($activeFilterCount)'
        : 'Filters';

    final buttons = Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        OutlinedPillButton(
          icon: Icons.print_outlined,
          label: 'Print All Products',
          onPressed: onPrint,
        ),
        OutlinedPillButton(
          icon: Icons.tune,
          label: filterLabel,
          onPressed: onFilters,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [search, const SizedBox(height: 12), buttons],
          );
        }
        return Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: search,
                ),
              ),
            ),
            const SizedBox(width: 16),
            buttons,
          ],
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, size: 18, color: AppColors.error),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            message,
            style: const TextStyle(fontSize: 13, color: AppColors.error),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
