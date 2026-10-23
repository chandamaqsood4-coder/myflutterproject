import 'catalog_entry.dart';

/// Case-insensitive match on name or slug.
List<CatalogEntry> filterCatalogEntries(
  List<CatalogEntry> entries,
  String query,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return entries;
  return entries
      .where(
        (e) =>
            e.name.toLowerCase().contains(q) ||
            e.slug.toLowerCase().contains(q),
      )
      .toList(growable: false);
}
