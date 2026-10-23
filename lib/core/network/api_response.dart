import 'package:dio/dio.dart';

/// One page of a list endpoint.
class PagedList {
  const PagedList({
    required this.items,
    required this.total,
    required this.lastPage,
  });

  final List<Map<String, dynamic>> items;
  final int total;
  final int lastPage;
}

Map<String, dynamic> responseBody(Response<Map<String, dynamic>> response) {
  final body = response.data;
  if (body == null) throw const FormatException('Empty response.');
  return body;
}

/// Reads a list from `{success, message, data}` where `data` is either a list
/// or a paginator object (`data.data`, `data.items`, with `meta` / `total`).
PagedList parsePagedList(Map<String, dynamic> body) {
  final data = body['data'];
  final containers = <Map<String, dynamic>>[body];
  List<dynamic> raw = const [];

  if (data is List) {
    raw = data;
  } else if (data is Map<String, dynamic>) {
    containers.add(data);
    for (final key in const ['data', 'items', 'results']) {
      final candidate = data[key];
      if (candidate is List) {
        raw = candidate;
        break;
      }
    }
  }

  final items = raw.whereType<Map<String, dynamic>>().toList(growable: false);

  int? total;
  int? lastPage;
  for (final container in containers) {
    for (final source in [
      container,
      container['meta'],
      container['pagination'],
    ]) {
      if (source is Map<String, dynamic>) {
        total ??= parseInt(source['total']);
        lastPage ??= parseInt(source['last_page']);
      }
    }
  }

  return PagedList(
    items: items,
    total: total ?? items.length,
    lastPage: lastPage ?? 1,
  );
}

int? parseInt(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

double? parseDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

/// Converts a money value (number or numeric string) to minor units (paisa).
int? toMinorUnits(Object? value) {
  final amount = parseDouble(value);
  return amount == null ? null : (amount * 100).round();
}

/// Returns a trimmed non-empty string, or null.
String? nonEmptyString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
