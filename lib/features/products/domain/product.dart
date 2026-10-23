enum ProductStatus {
  active,
  paused,
  deleted;

  static ProductStatus parse(Object? value) {
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'paused' || lower == 'inactive') return ProductStatus.paused;
      if (lower == 'deleted') return ProductStatus.deleted;
      if (lower == 'active') return ProductStatus.active;
    }
    return ProductStatus.active;
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.unit,
    required this.sellingPriceMinor,
    required this.status,
    this.barcode,
    this.categoryName,
    this.brandName,
    this.categoryId,
    this.brandId,
    this.stockQty,
    this.minQuantityThreshold,
    this.purchasePriceMinor,
    this.description,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String sku;

  /// A string: barcodes can have leading zeros.
  final String? barcode;
  final String? categoryName;
  final String? brandName;
  final int? categoryId;
  final int? brandId;

  /// Exact stock on hand. Null when the API response did not include stock.
  final int? stockQty;
  final int? minQuantityThreshold;

  final String unit;

  /// Price in minor units (paisa).
  final int sellingPriceMinor;
  final int? purchasePriceMinor;
  final ProductStatus status;
  final String? description;
  final String? imageUrl;

  /// "Category · Brand", skipping whichever is missing.
  String get categoryAndBrand {
    final parts = [categoryName, brandName].whereType<String>().toList();
    return parts.isEmpty ? '—' : parts.join(' · ');
  }
}

class ProductDraft {
  const ProductDraft({
    required this.name,
    required this.sku,
    required this.sellingPriceMinor,
    this.purchasePriceMinor = 0,
    this.barcode,
    this.categoryId,
    this.brandId,
    this.unit = 'pc',
    this.status = ProductStatus.active,
    this.stockQty,
    this.minQuantityThreshold,
    this.description,
    this.imageUrl,
  });

  final String name;
  final String sku;
  final int sellingPriceMinor;
  final int purchasePriceMinor;
  final String? barcode;
  final int? categoryId;
  final int? brandId;
  final String unit;
  final ProductStatus status;
  final int? stockQty;
  final int? minQuantityThreshold;
  final String? description;
  final String? imageUrl;
}

class ProductPage {
  const ProductPage({required this.items, required this.total});

  final List<Product> items;

  /// Total matching products on the server (may exceed [items]).
  final int total;
}
