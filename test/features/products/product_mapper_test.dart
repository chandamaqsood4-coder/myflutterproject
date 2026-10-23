import 'package:dukan_os/features/products/data/product_mapper.dart';
import 'package:dukan_os/features/products/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps nested category and brand objects', () {
    final p = productFromJson({
      'id': 1,
      'name': '3-Core Flex Cable (50m)',
      'sku': 'MST-CBL-3C',
      'barcode': '8961000000603',
      'category': {'id': 3, 'name': 'Wires & Cables'},
      'brand': {'id': 2, 'name': 'Master Cables'},
      'unit': 'roll',
      'selling_price': '5900.00',
      'status': 'active',
      'inventory': {'quantity': -1},
    });

    expect(p.id, 1);
    expect(p.categoryAndBrand, 'Wires & Cables · Master Cables');
    expect(p.sellingPriceMinor, 590000);
    expect(p.stockQty, -1);
    expect(p.unit, 'roll');
    expect(p.status, ProductStatus.active);
    expect(p.barcode, '8961000000603');
  });

  test('maps flat names and nested stock', () {
    final p = productFromJson({
      'id': 2,
      'name': 'Ceiling Fan 48"',
      'sku': 'DWL-FAN-48',
      'category_name': 'Ceiling Fans',
      'selling_price': 6500,
      'status': 'paused',
      'stock': {'quantity': 19},
    });

    expect(p.categoryAndBrand, 'Ceiling Fans');
    expect(p.stockQty, 19);
    expect(p.unit, 'pc');
    expect(p.status, ProductStatus.paused);
    expect(p.barcode, isNull);
  });

  test('maps category/brand ids from objects and plain values', () {
    final p = productFromJson({
      'id': 4,
      'name': 'Bulb',
      'sku': 'BLB-1',
      'category': {'id': 7, 'name': 'Lights'},
      'brand_id': 3,
      'selling_price': 50,
    });

    expect(p.categoryId, 7);
    expect(p.brandId, 3);
  });

  test('handles stock as a plain number', () {
    final p = productFromJson({
      'id': 5,
      'name': 'Wire',
      'sku': 'WR-1',
      'selling_price': 10,
      'stock': 25,
    });

    expect(p.stockQty, 25);
  });

  test('missing stock stays null and missing names show a dash', () {
    final p = productFromJson({
      'id': 3,
      'name': 'Switch',
      'sku': 'SW-1',
      'selling_price': 95,
      'status': 'deleted',
    });

    expect(p.stockQty, isNull);
    expect(p.categoryAndBrand, '—');
    expect(p.status, ProductStatus.deleted);
  });

  test('throws when the id is missing', () {
    expect(
      () => productFromJson({'name': 'x', 'sku': 'y'}),
      throwsFormatException,
    );
  });

  test('only sends opening stock when creating', () {
    const draft = ProductDraft(
      name: 'Cable',
      sku: 'CBL-1',
      sellingPriceMinor: 1000,
      stockQty: 5,
    );

    final create = productDraftToJson(draft, includeOpeningQuantity: true);
    final update = productDraftToJson(draft);

    expect(create['opening_quantity'], 5);
    expect(update.containsKey('opening_quantity'), isFalse);
  });

  test('reads the uploaded image url from common response shapes', () {
    expect(
      imageUrlFromJson({
        'data': {'url': 'a.png'},
      }),
      'a.png',
    );
    expect(
      imageUrlFromJson({
        'data': {'path': 'b.png'},
      }),
      'b.png',
    );
    expect(imageUrlFromJson({'url': 'c.png'}), 'c.png');
    expect(imageUrlFromJson({'data': {}}), isNull);
  });
}
