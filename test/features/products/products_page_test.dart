import 'dart:typed_data';

import 'package:dukan_os/features/auth/presentation/providers/auth_providers.dart';
import 'package:dukan_os/features/products/domain/product.dart';
import 'package:dukan_os/features/products/domain/product_repository.dart';
import 'package:dukan_os/features/products/presentation/products_page.dart';
import 'package:dukan_os/features/products/presentation/providers/product_providers.dart';
import 'package:dukan_os/shared/design_system/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repository double so the page never touches the network.
class _FakeProductRepository implements ProductRepository {
  @override
  Future<ProductPage> fetchProducts({
    String search = '',
    int perPage = 100,
  }) async => const ProductPage(items: _products, total: 3);

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

const List<Product> _products = [
  Product(
    id: 1,
    name: 'Inverter Air Conditioner 1.5 Ton Split',
    sku: 'AC-INV-1500',
    barcode: '8964000123456',
    categoryName: 'Air Conditioners',
    brandName: 'Dawlance',
    stockQty: 12,
    unit: 'pcs',
    sellingPriceMinor: 18999900,
    status: ProductStatus.active,
  ),
  Product(
    id: 2,
    name: 'LED TV 43 inch Smart',
    sku: 'TV-LED-43',
    categoryName: 'Televisions',
    brandName: 'Toshiba',
    stockQty: 0,
    unit: 'pcs',
    sellingPriceMinor: 7999000,
    status: ProductStatus.paused,
  ),
  Product(
    id: 3,
    name: 'Refrigerator Double Door 320L',
    sku: 'RF-DDB-320',
    categoryName: 'Refrigerators',
    brandName: 'Haier',
    stockQty: 4,
    unit: 'pcs',
    sellingPriceMinor: 11599900,
    status: ProductStatus.active,
  ),
];

Widget _harness(Widget child) => ProviderScope(
  overrides: [
    productRepositoryProvider.overrideWithValue(_FakeProductRepository()),
    currentPermissionsProvider.overrideWithValue(const {
      'products.view',
      'products.create',
      'products.update',
      'products.delete',
    }),
  ],
  child: MaterialApp(
    theme: AppTheme.light(),
    // The shell renders the page inside its Scaffold, which provides the
    // Material ancestor the inputs need.
    home: Scaffold(body: child),
  ),
);

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_harness(const ProductsPage()));
  await tester.pump();
}

void main() {
  testWidgets('renders the products table without layout overflow', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const Size(1280, 900));

    expect(find.text('Products & Stock'), findsOneWidget);
    expect(find.text('Inverter Air Conditioner 1.5 Ton Split'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders on a narrow window without layout overflow', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const Size(800, 600));

    expect(find.text('Products & Stock'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders at the minimum window size without layout overflow', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const Size(480, 640));

    expect(find.text('Products & Stock'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders at a large text scale without layout overflow', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pump(tester, const Size(1280, 900));

    expect(tester.takeException(), isNull);
  });
}
