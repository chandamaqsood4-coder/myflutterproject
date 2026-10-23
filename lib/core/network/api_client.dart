import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

typedef TokenReader = String? Function();

/// Creates the shared HTTP client.
///
/// Intentionally has no body/header logging: requests carry passwords and
/// responses carry bearer tokens.
///
/// [onUnauthorized] runs when any request except login gets a 401, so the app
/// can drop the expired session.
Dio createApiClient({
  String? baseUrl,
  TokenReader? tokenReader,
  VoidCallback? onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      sendTimeout: AppConfig.sendTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: const {'Accept': 'application/json'},
      contentType: Headers.jsonContentType,
    ),
  );

  if (tokenReader != null) {
    dio.interceptors.add(_BearerTokenInterceptor(tokenReader));
  }
  if (onUnauthorized != null) {
    dio.interceptors.add(_UnauthorizedInterceptor(onUnauthorized));
  }
  return dio;
}

class _BearerTokenInterceptor extends Interceptor {
  _BearerTokenInterceptor(this._readToken);

  final TokenReader _readToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _UnauthorizedInterceptor extends Interceptor {
  _UnauthorizedInterceptor(this._onUnauthorized);

  final VoidCallback _onUnauthorized;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isLogin = err.requestOptions.path.endsWith('/auth/login');
    if (err.response?.statusCode == 401 && !isLogin) {
      _onUnauthorized();
    }
    handler.next(err);
  }
}
