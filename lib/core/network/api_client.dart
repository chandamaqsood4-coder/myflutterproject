import 'package:dio/dio.dart';

import '../config/app_config.dart';

typedef TokenReader = String? Function();

/// Creates the shared HTTP client.
///
/// Intentionally has no body/header logging: requests carry passwords and
/// responses carry bearer tokens.
Dio createApiClient({String? baseUrl, TokenReader? tokenReader}) {
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
