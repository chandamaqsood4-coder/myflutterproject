import 'package:dukan_os/features/catalog/data/catalog_mapper.dart';
import 'package:dukan_os/features/catalog/domain/catalog_entry.dart';
import 'package:dukan_os/features/catalog/domain/catalog_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a category', () {
    final e = catalogEntryFromJson({
      'id': 5,
      'name': 'LED Bulbs',
      'slug': 'led_bulbs',
      'status': 'active',
      'description': 'Bulbs',
      'products_count': 5,
      'parent_id': 2,
      'sort_order': 3,
    });

    expect(e.id, 5);
    expect(e.isActive, isTrue);
    expect(e.linkedProducts, 5);
    expect(e.parentId, 2);
    expect(e.sortOrder, 3);
    expect(e.description, 'Bulbs');
  });

  test('inactive status and missing count', () {
    final e = catalogEntryFromJson({
      'id': 6,
      'name': 'Old',
      'slug': 'old',
      'status': 'inactive',
    });

    expect(e.isActive, isFalse);
    expect(e.linkedProducts, isNull);
  });

  test('draft body matches the API fields', () {
    final body = catalogDraftToJson(
      const CatalogDraft(
        name: 'Fans',
        slug: 'fans',
        isActive: false,
        description: 'Cooling',
        parentId: 1,
      ),
    );

    expect(body, {
      'name': 'Fans',
      'slug': 'fans',
      'status': 'inactive',
      'description': 'Cooling',
      'parent_id': 1,
    });
  });

  test('filters by name or slug', () {
    const entries = [
      CatalogEntry(id: 1, name: 'LED Bulbs', slug: 'led_bulbs', isActive: true),
      CatalogEntry(
        id: 2,
        name: 'Tube Lights',
        slug: 'tube_lights',
        isActive: true,
      ),
    ];

    expect(filterCatalogEntries(entries, 'led').single.id, 1);
    expect(filterCatalogEntries(entries, 'TUBE_').single.id, 2);
    expect(filterCatalogEntries(entries, ' '), entries);
    expect(filterCatalogEntries(entries, 'zzz'), isEmpty);
  });
}
