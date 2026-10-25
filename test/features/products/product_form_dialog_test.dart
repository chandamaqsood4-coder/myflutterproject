import 'dart:typed_data';

import 'package:dukan_os/features/catalog/domain/catalog_entry.dart';
import 'package:dukan_os/features/catalog/domain/catalog_repository.dart';
import 'package:dukan_os/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:dukan_os/features/products/domain/product.dart';
import 'package:dukan_os/features/products/domain/product_repository.dart';
import 'package:dukan_os/features/products/presentation/providers/product_providers.dart';
import 'package:dukan_os/features/products/presentation/widgets/product_form_dialog.dart';
import 'package:dukan_os/shared/design_system/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProductRepository implements ProductRepository {
  @override
  Future<ProductPage> fetchProducts({
    String search = '',
    int perPage = 100,
  }) async => const ProductPage(items: [], total: 0);

  @override
  Future<Product?> fetchProduct(int id) async => null;

  @override
  Future<Product?> createProduct(ProductDraft draft) async => null;

  @override
  Future<Product?> updateProduct(int id, ProductDraft draft) async => null;

  @override
  Future<void> adjustStock(int id, int delta, {String? note}) async {}

  @override
  Future<String> uploadImage({
    required Uint8List bytes,
    required String filename,
  }) async => 'https://example.com/image.png';

  @override
  Future<void> deleteProduct(int id) async {}
}

/// The API does not return the product's linked entries in this test, which
/// used to make the dropdown assert because its value was not in the items.
class _FakeCatalogRepository implements CatalogRepository {
  @override
  Future<List<CatalogEntry>> fetch(CatalogKind kind) async => const [];

  @override
  Future<void> create(CatalogKind kind, CatalogDraft draft) async {}

  @override
  Future<void> update(CatalogKind kind, int id, CatalogDraft draft) async {}

  @override
  Future<void> delete(CatalogKind kind, int id) async {}
}

const Product _product = Product(
  id: 7,
  name: 'Cable',
  sku: 'CBL-1',
  unit: 'pc',
  sellingPriceMinor: 199900,
  categoryId: 3,
  categoryName: 'Legacy Category',
  brandId: 4,
  brandName: 'Legacy Brand',
  stockQty: 5,
  status: ProductStatus.active,
);

Widget _harness() {
  return ProviderScope(
    overrides: [
      productRepositoryProvider.overrideWithValue(_FakeProductRepository()),
      catalogRepositoryProvider.overrideWithValue(_FakeCatalogRepository()),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const ProductFormDialog(product: _product),
              ),
              child: const Text('Open form'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('keeps linked category and brand when the list omits them', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_harness());
    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Product'), findsOneWidget);
    expect(find.text('Legacy Category'), findsOneWidget);
    expect(find.text('Legacy Brand'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
