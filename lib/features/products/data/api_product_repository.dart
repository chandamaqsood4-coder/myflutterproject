import 'dart:typed_data';

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
        // The API applies the opening stock as part of the create request.
        // Adjusting afterwards would add it twice.
        data: productDraftToJson(draft, includeOpeningQuantity: true),
      );
      final body = responseBody(response);
      final data = body['data'];
      if (data is Map<String, dynamic>) return productFromJson(data);
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
            await adjustStock(
              id,
              delta,
              note: 'Stock updated from product edit',
            );
          } on ApiException catch (e) {
            // The product fields are already saved, but stock is now out of
            // sync. Tell the user instead of hiding the partial failure.
            throw ApiException(
              e.type,
              'Product details were saved, but stock could not be updated: '
              '${e.message}',
              statusCode: e.statusCode,
            );
          }
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
  Future<String> uploadImage({
    required Uint8List bytes,
    required String filename,
  }) {
    return guardApi(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/products/upload-image',
        data: FormData.fromMap({
          'image': MultipartFile.fromBytes(bytes, filename: filename),
        }),
      );
      final url = imageUrlFromJson(responseBody(response));
      if (url == null) {
        throw const ApiException(
          ApiFailureType.unexpected,
          'Image uploaded but no URL was returned.',
        );
      }
      return url;
    });
  }

  @override
  Future<void> deleteProduct(int id) {
    return guardApi(() async {
      await _dio.delete<Object?>('/products/$id');
    });
  }
}
