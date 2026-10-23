import 'package:dukan_os/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatPkr', () {
    test('formats minor units with grouping and two decimals', () {
      expect(formatPkr(0), 'PKR 0.00');
      expect(formatPkr(5), 'PKR 0.05');
      expect(formatPkr(5430000), 'PKR 54,300.00');
      expect(formatPkr(34909660), 'PKR 349,096.60');
      expect(formatPkr(100000000), 'PKR 1,000,000.00');
    });

    test('formats negative amounts', () {
      expect(formatPkr(-150), '-PKR 1.50');
    });
  });

  test('formatShortDate', () {
    expect(formatShortDate(DateTime(2026, 8, 28)), '28 Aug 2026');
    expect(formatShortDate(DateTime(2026, 1, 5)), '5 Jan 2026');
  });

  test('formatQuantity trims trailing zeros', () {
    expect(formatQuantity(19), '19');
    expect(formatQuantity(-1), '-1');
    expect(formatQuantity(0), '0');
    expect(formatQuantity(100), '100');
    expect(formatQuantity(2.5), '2.5');
    expect(formatQuantity(0.125), '0.125');
  });

  group('parseMinorUnits', () {
    test('parses valid money strings', () {
      expect(parseMinorUnits('0'), 0);
      expect(parseMinorUnits('0.00'), 0);
      expect(parseMinorUnits('54,300'), 5430000);
      expect(parseMinorUnits('19.99'), 1999);
      expect(parseMinorUnits('0.5'), 50);
    });

    test('rejects invalid money strings', () {
      expect(parseMinorUnits(''), isNull);
      expect(parseMinorUnits('abc'), isNull);
      expect(parseMinorUnits('-5'), isNull);
      expect(parseMinorUnits('5.123'), isNull);
      expect(parseMinorUnits('5,300.00.00'), isNull);
    });
  });
}
