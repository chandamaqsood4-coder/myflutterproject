import 'dart:typed_data';

import 'package:dukan_os/features/auth/presentation/providers/auth_providers.dart';
import 'package:dukan_os/features/products/domain/product.dart';
import 'package:dukan_os/features/products/domain/product_repository.dart';
import 'package:dukan_os/features/products/presentation/providers/product_providers.dart';
import 'package:dukan_os/features/products/presentation/widgets/product_detail_dialog.dart';
import 'package:dukan_os/shared/design_system/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository(this.product);

  final Product product;

  @override
  Future<ProductPage> fetchProducts({
    String search = '',
    int perPage = 100,
  }) async => ProductPage(items: [product], total: 1);

  @override
  Future<Product?> fetchProduct(int id) async => product;

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

const Product _product = Product(
  id: 7,
  name: 'Cable',
  sku: 'Mc',
  categoryName: 'ups',
  brandName: 'Clipsal',
  unit: 'pc',
  stockQty: 10,
  minQuantityThreshold: 0,
  sellingPriceMinor: 199900,
  purchasePriceMinor: 150000,
  status: ProductStatus.active,
);

Widget _harness({Set<String> permissions = const {'products.update'}}) {
  return ProviderScope(
    overrides: [
      productRepositoryProvider.overrideWithValue(
        _FakeProductRepository(_product),
      ),
      currentPermissionsProvider.overrideWithValue(permissions),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const ProductDetailDialog(product: _product),
              ),
              child: const Text('Open detail'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _open(
  WidgetTester tester, {
  Size size = const Size(1280, 900),
  Set<String> permissions = const {'products.update'},
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_harness(permissions: permissions));
  await tester.tap(find.text('Open detail'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the product overview sections', (
    WidgetTester tester,
  ) async {
    await _open(tester);

    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('SKU: Mc'), findsOneWidget);
    expect(find.text('Product Images'), findsOneWidget);
    expect(find.text('Product Information'), findsOneWidget);
    expect(find.text('Pricing & Profitability'), findsOneWidget);
    expect(find.text('Stock & Inventory'), findsOneWidget);
    expect(find.text('Sales Information'), findsOneWidget);
    expect(find.text('Sales History'), findsOneWidget);
    expect(find.text('ups'), findsAtLeastNWidgets(1));
    expect(find.text('Clipsal'), findsOneWidget);
    expect(find.text('PKR 1,999.00'), findsOneWidget);
    expect(find.text('PKR 1,500.00'), findsOneWidget);
    expect(find.text('PKR 499.00'), findsOneWidget);
    expect(find.text('33.3%'), findsOneWidget);
    expect(find.text('PKR 15,000.00'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow on a narrow window', (
    WidgetTester tester,
  ) async {
    await _open(tester, size: const Size(480, 800));

    expect(find.text('Product Information'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow at a large text scale', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _open(tester);

    expect(find.text('Product Information'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides the edit action without permission', (
    WidgetTester tester,
  ) async {
    await _open(tester, permissions: const {'products.view'});

    expect(find.text('Edit'), findsNothing);
    expect(find.text('Product Information'), findsOneWidget);
  });
}
