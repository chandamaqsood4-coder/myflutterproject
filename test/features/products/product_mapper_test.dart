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
}
