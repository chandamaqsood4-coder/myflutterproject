import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/api_catalog_repository.dart';
import '../../domain/catalog_entry.dart';
import '../../domain/catalog_repository.dart';
import '../../../products/presentation/providers/product_providers.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => ApiCatalogRepository(ref.watch(dioProvider)),
);

final catalogEntriesProvider =
    FutureProvider.family<List<CatalogEntry>, CatalogKind>((ref, kind) async {
      final entries = await ref.watch(catalogRepositoryProvider).fetch(kind);
      if (kind == CatalogKind.unit) return entries;

      final productsResult = ref.watch(productsProvider(''));
      return productsResult.when(
        data: (productPage) {
          final countsByCategory = <int, int>{};
          final countsByBrand = <int, int>{};

          for (final p in productPage.items) {
            if (p.categoryId != null) {
              countsByCategory[p.categoryId!] =
                  (countsByCategory[p.categoryId!] ?? 0) + 1;
            }
            if (p.brandId != null) {
              countsByBrand[p.brandId!] = (countsByBrand[p.brandId!] ?? 0) + 1;
            }
          }

          return entries.map((e) {
            final computed = kind == CatalogKind.category
                ? countsByCategory[e.id]
                : countsByBrand[e.id];
return CatalogEntry(
                id: e.id,
                name: e.name,
                slug: e.slug,
                isActive: e.isActive,
                description: e.description,
                linkedProducts: computed ?? 0,
                parentId: e.parentId,
                sortOrder: e.sortOrder,
              );
          }).toList();
        },
        loading: () => entries,
        error: (_, _) => entries,
      );
    });
