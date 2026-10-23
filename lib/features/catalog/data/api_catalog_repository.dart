import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../domain/catalog_entry.dart';
import '../domain/catalog_repository.dart';
import 'catalog_mapper.dart';

class ApiCatalogRepository implements CatalogRepository {
  ApiCatalogRepository(this._dio);

  static const int _perPage = 100;
  static const int _maxPages = 50;

  final Dio _dio;

  static const ApiException _unitsUnsupported = ApiException(
    ApiFailureType.unexpected,
    'Units are not managed here yet. Set the unit on each product.',
  );

  String _path(CatalogKind kind) => switch (kind) {
    CatalogKind.category => '/categories',
    CatalogKind.brand => '/brands',
    CatalogKind.unit => throw _unitsUnsupported,
  };

  @override
  Future<List<CatalogEntry>> fetch(CatalogKind kind) {
    // The API has no units endpoint.
    if (kind == CatalogKind.unit) return Future.value(const []);

    return guardApi(() async {
      final entries = <CatalogEntry>[];
      var page = 1;
      var lastPage = 1;
      do {
        final response = await _dio.get<Map<String, dynamic>>(
          _path(kind),
          queryParameters: {'per_page': _perPage, 'page': page},
        );
        final list = parsePagedList(responseBody(response));
        entries.addAll(list.items.map(catalogEntryFromJson));
        lastPage = list.lastPage;
        page++;
      } while (page <= lastPage && page <= _maxPages);
      return entries;
    });
  }

  @override
  Future<void> create(CatalogKind kind, CatalogDraft draft) {
    return guardApi(() async {
      await _dio.post<Object?>(_path(kind), data: catalogDraftToJson(draft));
    });
  }

  @override
  Future<void> update(CatalogKind kind, int id, CatalogDraft draft) {
    return guardApi(() async {
      await _dio.put<Object?>(
        '${_path(kind)}/$id',
        data: catalogDraftToJson(draft),
      );
    });
  }

  @override
  Future<void> delete(CatalogKind kind, int id) {
    return guardApi(() async {
      await _dio.delete<Object?>('${_path(kind)}/$id');
    });
  }
}
