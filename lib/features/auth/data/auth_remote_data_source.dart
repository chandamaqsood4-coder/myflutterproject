import 'package:dio/dio.dart';

import '../domain/auth_exception.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// POST /auth/login. Returns the `data` object of the response.
  /// Throws [DioException] for transport and HTTP errors.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final body = response.data;
    if (body == null) {
      throw const FormatException('Empty login response.');
    }
    if (body['success'] != true) {
      final message = body['message'];
      throw AuthException(
        AuthFailureType.invalidCredentials,
        message is String && message.isNotEmpty
            ? message
            : 'Incorrect email or password.',
      );
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Login response has no data.');
    }
    return data;
  }
}
