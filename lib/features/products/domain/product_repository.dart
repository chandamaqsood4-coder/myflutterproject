import 'product.dart';

abstract interface class ProductRepository {
  /// Searches by name, SKU or barcode. Throws `ApiException`.
  Future<ProductPage> fetchProducts({String search = '', int perPage = 100});

  /// Fetches a single product. Throws `ApiException`.
  Future<Product?> fetchProduct(int id);

  /// Creates a product. Returns the created product when possible.
  Future<Product?> createProduct(ProductDraft draft);

  /// Updates a product. Returns the updated product when possible.
  Future<Product?> updateProduct(int id, ProductDraft draft);

  /// Adjusts stock by [delta] (positive adds stock). Throws `ApiException`.
  Future<void> adjustStock(int id, int delta, {String? note});

  Future<void> deleteProduct(int id);
}
