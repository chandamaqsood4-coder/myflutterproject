import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/api_product_repository.dart';
import '../../domain/product.dart';
import '../../domain/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ApiProductRepository(ref.watch(dioProvider)),
);

/// Products matching a search query (empty = all). Searching runs on the
/// server, so large catalogs are never loaded in full.
final productsProvider = FutureProvider.family<ProductPage, String>(
  (ref, query) =>
      ref.watch(productRepositoryProvider).fetchProducts(search: query),
);

final productDetailProvider = FutureProvider.family<Product?, int>(
  (ref, id) => ref.watch(productRepositoryProvider).fetchProduct(id),
);

class SelectedProductNotifier extends Notifier<Product?> {
  @override
  Product? build() => null;

  @override
  set state(Product? value) => super.state = value;

  void select(Product? product) => state = product;

  void clear() => state = null;
}

/// Currently viewed product for the detail view page. When null, the products table is shown.
final selectedProductDetailProvider =
    NotifierProvider<SelectedProductNotifier, Product?>(
      SelectedProductNotifier.new,
    );

class EditingProductNotifier extends Notifier<Product?> {
  @override
  Product? build() => null;

  @override
  set state(Product? value) => super.state = value;

  void edit(Product? product) => state = product;

  void clear() => state = null;
}

/// Currently edited product for the full-page edit view. When null, normal view is shown.
final editingProductProvider =
    NotifierProvider<EditingProductNotifier, Product?>(
      EditingProductNotifier.new,
    );
