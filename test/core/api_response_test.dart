import 'package:dukan_os/core/network/api_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsePagedList', () {
    test('data is a plain list', () {
      final list = parsePagedList({
        'success': true,
        'data': [
          {'id': 1},
          {'id': 2},
        ],
      });
      expect(list.items.length, 2);
      expect(list.total, 2);
      expect(list.lastPage, 1);
    });

    test('data.data with meta', () {
      final list = parsePagedList({
        'data': {
          'data': [
            {'id': 1},
          ],
          'meta': {'total': 40, 'last_page': 4},
        },
      });
      expect(list.items.length, 1);
      expect(list.total, 40);
      expect(list.lastPage, 4);
    });

    test('paginator fields at the top level of data', () {
      final list = parsePagedList({
        'data': {
          'data': [
            {'id': 1},
          ],
          'total': 7,
          'last_page': 2,
        },
      });
      expect(list.total, 7);
      expect(list.lastPage, 2);
    });

    test('meta beside data', () {
      final list = parsePagedList({
        'data': [
          {'id': 1},
        ],
        'meta': {'total': 12, 'last_page': 3},
      });
      expect(list.total, 12);
      expect(list.lastPage, 3);
    });

    test('missing data gives an empty list', () {
      final list = parsePagedList({'success': true});
      expect(list.items, isEmpty);
      expect(list.total, 0);
    });
  });

  group('number parsing', () {
    test('toMinorUnits handles numbers and strings', () {
      expect(toMinorUnits(5900), 590000);
      expect(toMinorUnits('5900.00'), 590000);
      expect(toMinorUnits(19.99), 1999);
      expect(toMinorUnits(null), isNull);
      expect(toMinorUnits('abc'), isNull);
    });

    test('parseInt and parseDouble', () {
      expect(parseInt('12'), 12);
      expect(parseInt(12.0), 12);
      expect(parseDouble('2.5'), 2.5);
      expect(parseInt(null), isNull);
    });
  });
}
