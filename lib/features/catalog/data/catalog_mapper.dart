import '../../../core/network/api_response.dart';
import '../domain/catalog_entry.dart';

/// Parses a category or brand object. The linked-product count is read from
/// a few likely field names until the exact response is confirmed.
CatalogEntry catalogEntryFromJson(Map<String, dynamic> json) {
  return CatalogEntry(
    id:
        parseInt(json['id']) ??
        (throw const FormatException('Catalog entry has no id.')),
    name: json['name'] as String,
    slug: (json['slug'] as String?) ?? '',
    isActive: json['status'] != 'inactive',
    description: nonEmptyString(json['description']),
    linkedProducts: _linkedProducts(json),
    parentId: parseInt(json['parent_id']),
    sortOrder: parseInt(json['sort_order']),
  );
}

int? _linkedProducts(Map<String, dynamic> json) {
  for (final key in const [
    'products_count',
    'linked_products',
    'linked_products_count',
    'product_count',
  ]) {
    final value = parseInt(json[key]);
    if (value != null) return value;
  }
  return null;
}

/// Request body for create and update.
Map<String, dynamic> catalogDraftToJson(CatalogDraft draft) => {
  'name': draft.name,
  'slug': draft.slug,
  'status': draft.isActive ? 'active' : 'inactive',
  if (draft.description != null) 'description': draft.description,
  if (draft.parentId != null) 'parent_id': draft.parentId,
  if (draft.sortOrder != null) 'sort_order': draft.sortOrder,
};
