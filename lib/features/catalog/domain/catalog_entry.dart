enum CatalogKind { category, brand, unit }

/// A category or brand. (Units are plain text on products; the API has no
/// units endpoint.)
class CatalogEntry {
  const CatalogEntry({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
    this.description,
    this.linkedProducts,
    this.parentId,
    this.sortOrder,
  });

  final int id;
  final String name;
  final String slug;
  final bool isActive;
  final String? description;

  /// Null when the API response did not include a product count.
  final int? linkedProducts;

  /// Categories only.
  final int? parentId;
  final int? sortOrder;
}

/// Editable fields sent on create and update.
class CatalogDraft {
  const CatalogDraft({
    required this.name,
    required this.slug,
    required this.isActive,
    this.description,
    this.parentId,
    this.sortOrder,
  });

  final String name;
  final String slug;
  final bool isActive;
  final String? description;
  final int? parentId;
  final int? sortOrder;
}
