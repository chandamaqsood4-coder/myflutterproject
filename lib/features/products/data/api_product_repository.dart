import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../domain/product.dart';
import '../domain/product_repository.dart';
import 'product_mapper.dart';

class ApiProductRepository implements ProductRepository {
  ApiProductRepository(this._dio);

  final Dio _dio;

  /// The platform web client loads products with `per_page=10000`.
  static const int _perPage = 10000;

  @override
  Future<ProductPage> fetchProducts({String search = '', int perPage = 100}) {
    return guardApi(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/products',
        queryParameters: {'per_page': _perPage},
      );
      final list = parsePagedList(responseBody(response));
      var items = list.items.map(productFromJson).toList(growable: false);
      final q = search.trim().toLowerCase();
      if (q.isNotEmpty) {
        items = items
            .where(
              (p) =>
                  p.name.toLowerCase().contains(q) ||
                  p.sku.toLowerCase().contains(q) ||
                  (p.barcode?.toLowerCase().contains(q) ?? false),
            )
            .toList(growable: false);
      }
      return ProductPage(items: items, total: items.length);
    });
  }

  @override
  Future<Product?> fetchProduct(int id) {
    return guardApi(() async {
      final response = await _dio.get<Map<String, dynamic>>('/products/$id');
      final body = responseBody(response);
      final data = body['data'];
      if (data is Map<String, dynamic>) return productFromJson(data);
      if (data is List &&
          data.isNotEmpty &&
          data.first is Map<String, dynamic>) {
        return productFromJson(data.first as Map<String, dynamic>);
      }
      if (body['product'] is Map<String, dynamic>) {
        return productFromJson(body['product'] as Map<String, dynamic>);
      }
      return null;
    });
  }

  @override
  Future<Product?> createProduct(ProductDraft draft) {
    return guardApi(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/products',
        data: productDraftToJson(draft),
      );
      final body = responseBody(response);
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        final product = productFromJson(data);
        final stock = draft.stockQty ?? 0;
        if (stock != 0) {
          try {
            await _dio.post<Object?>(
              '/inventory/${product.id}/adjust',
              data: {'delta': stock, 'note': 'Opening stock'},
            );
          } catch (_) {}
        }
        return product;
      }
      return null;
    });
  }

  @override
  Future<Product?> updateProduct(int id, ProductDraft draft) {
    return guardApi(() async {
      final current = await fetchProduct(id);
      final response = await _dio.put<Map<String, dynamic>>(
        '/products/$id',
        data: productDraftToJson(draft),
      );
      final body = responseBody(response);
      final data = body['data'];
      final updated = data is Map<String, dynamic>
          ? productFromJson(data)
          : null;

      final desired = draft.stockQty;
      final existing = current?.stockQty;
      if (desired != null && existing != null && desired != existing) {
        final delta = desired - existing;
        if (delta != 0) {
          try {
            await _dio.post<Object?>(
              '/inventory/$id/adjust',
              data: {'delta': delta, 'note': 'Stock updated from product edit'},
            );
          } catch (_) {}
        }
      }
      return updated ?? current;
    });
  }

  @override
  Future<void> adjustStock(int id, int delta, {String? note}) {
    return guardApi(() async {
      await _dio.post<Object?>(
        '/inventory/$id/adjust',
        data: {
          'delta': delta,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
    });
  }

  @override
  Future<void> deleteProduct(int id) {
    return guardApi(() async {
      await _dio.delete<Object?>('/products/$id');
    });
  }
}
