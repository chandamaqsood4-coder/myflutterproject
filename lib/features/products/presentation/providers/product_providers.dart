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
