import 'catalog_entry.dart';

/// All methods throw `ApiException` on failure.
abstract interface class CatalogRepository {
  Future<List<CatalogEntry>> fetch(CatalogKind kind);
  Future<void> create(CatalogKind kind, CatalogDraft draft);
  Future<void> update(CatalogKind kind, int id, CatalogDraft draft);
  Future<void> delete(CatalogKind kind, int id);
}
