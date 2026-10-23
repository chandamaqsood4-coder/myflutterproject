import '../../../core/network/api_response.dart';
import '../domain/product.dart';

/// Parses one product object from the DukanOS API.
///
/// Verified shapes from the web client:
/// - stock lives under `inventory.quantity` (also sometimes `current_stock`)
/// - category/brand may be objects `{id,name}` or flat strings
/// - selling/purchase prices may be numbers or numeric strings
Product productFromJson(Map<String, dynamic> json) {
  final inventory = json['inventory'];
  final inventoryMap = inventory is Map<String, dynamic> ? inventory : null;

  return Product(
    id:
        parseInt(json['id']) ??
        (throw const FormatException('Product has no id.')),
    name: (json['name'] as String?) ?? '',
    sku: (json['sku'] as String?) ?? '',
    barcode: nonEmptyString(json['barcode']),
    categoryName:
        _textOrName(json['category']) ?? nonEmptyString(json['category_name']),
    brandName: _textOrName(json['brand']) ?? nonEmptyString(json['brand_name']),
    unit: _textOrName(json['unit']) ?? nonEmptyString(json['unit']) ?? 'pc',
    sellingPriceMinor: toMinorUnits(json['selling_price']) ?? 0,
    purchasePriceMinor: toMinorUnits(
      json['purchase_cost'] ?? json['purchase_price'] ?? json['cost_price'],
    ),
    status: ProductStatus.parse(json['status']),
    stockQty: _stockQty(json, inventoryMap),
    minQuantityThreshold:
        parseInt(json['min_quantity_threshold']) ??
        parseInt(inventoryMap?['min_quantity_threshold']),
    description: nonEmptyString(json['description']),
    imageUrl:
        nonEmptyString(json['image']) ??
        nonEmptyString(json['image_url']) ??
        _galleryFirst(json['gallery']),
  );
}

String? _textOrName(Object? value) {
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    // If it's just an id string, ignore.
    if (int.tryParse(trimmed) != null) return null;
    return trimmed;
  }
  if (value is Map<String, dynamic>) return nonEmptyString(value['name']);
  return null;
}

String? _galleryFirst(Object? value) {
  if (value is List && value.isNotEmpty) {
    final first = value.first;
    if (first is String) return nonEmptyString(first);
    if (first is Map<String, dynamic>) {
      return nonEmptyString(first['url']) ??
          nonEmptyString(first['image']) ??
          nonEmptyString(first['path']);
    }
  }
  return null;
}

int? _stockQty(Map<String, dynamic> json, Map<String, dynamic>? inventoryMap) {
  for (final source in [inventoryMap, json['inventory'], json['stock'], json]) {
    if (source is Map<String, dynamic>) {
      for (final key in const [
        'quantity',
        'current_stock',
        'stock_quantity',
        'available_quantity',
        'stock',
        'on_hand',
      ]) {
        final parsed = parseInt(source[key]);
        if (parsed != null) return parsed;
      }
    }
  }
  return null;
}

String _statusToApi(ProductStatus status) => switch (status) {
  ProductStatus.active => 'active',
  ProductStatus.paused => 'inactive',
  ProductStatus.deleted => 'deleted',
};

Map<String, dynamic> productDraftToJson(ProductDraft draft) {
  final price = (draft.sellingPriceMinor / 100).toStringAsFixed(2);
  final cost = ((draft.purchasePriceMinor) / 100).toStringAsFixed(2);
  return {
    'name': draft.name.trim(),
    'sku': draft.sku.trim(),
    if (draft.barcode != null && draft.barcode!.trim().isNotEmpty)
      'barcode': draft.barcode!.trim(),
    if (draft.categoryId != null) 'category_id': draft.categoryId,
    if (draft.brandId != null) 'brand_id': draft.brandId,
    'unit': draft.unit.trim().isEmpty ? 'pc' : draft.unit.trim(),
    'selling_price': price,
    'purchase_cost': cost,
    'status': _statusToApi(draft.status),
    'opening_quantity': draft.stockQty ?? 0,
    if (draft.minQuantityThreshold != null)
      'min_quantity_threshold': draft.minQuantityThreshold,
    if (draft.description != null && draft.description!.trim().isNotEmpty)
      'description': draft.description!.trim(),
    if (draft.imageUrl != null && draft.imageUrl!.trim().isNotEmpty)
      'image': draft.imageUrl!.trim(),
  };
}
