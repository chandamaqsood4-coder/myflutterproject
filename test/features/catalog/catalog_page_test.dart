import 'package:dukan_os/features/auth/presentation/providers/auth_providers.dart';
import 'package:dukan_os/features/catalog/domain/catalog_entry.dart';
import 'package:dukan_os/features/catalog/domain/catalog_repository.dart';
import 'package:dukan_os/features/catalog/presentation/catalog_page.dart';
import 'package:dukan_os/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:dukan_os/shared/design_system/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repository double so the page never touches the network.
class _FakeCatalogRepository implements CatalogRepository {
  @override
  Future<List<CatalogEntry>> fetch(CatalogKind kind) async => _entries;

  @override
  Future<void> create(CatalogKind kind, CatalogDraft draft) async {}

  @override
  Future<void> update(CatalogKind kind, int id, CatalogDraft draft) async {}

  @override
  Future<void> delete(CatalogKind kind, int id) async {}
}

const List<CatalogEntry> _entries = [
  CatalogEntry(
    id: 1,
    name: 'Air Conditioners & Air Purifiers',
    slug: 'air-conditioners',
    isActive: true,
    linkedProducts: 42,
  ),
  CatalogEntry(
    id: 2,
    name: 'Televisions',
    slug: 'televisions',
    isActive: true,
    linkedProducts: 17,
  ),
  CatalogEntry(
    id: 3,
    name: 'Refrigerators',
    slug: 'refrigerators',
    isActive: false,
    linkedProducts: 0,
  ),
];

Widget _harness(Widget child) => ProviderScope(
  overrides: [
    catalogRepositoryProvider.overrideWithValue(_FakeCatalogRepository()),
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

  await tester.pumpWidget(_harness(const CatalogPage()));
  await tester.pump();
}

void main() {
  testWidgets('renders the catalog table without layout overflow', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const Size(1280, 900));

    expect(find.text('Categories, Brands & Units'), findsOneWidget);
    expect(find.text('Air Conditioners & Air Purifiers'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders on a narrow window without layout overflow', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const Size(800, 600));

    expect(find.text('Categories, Brands & Units'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders at the minimum window size without layout overflow', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const Size(480, 640));

    expect(find.text('Categories, Brands & Units'), findsOneWidget);
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
