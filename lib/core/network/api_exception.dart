import 'package:dio/dio.dart';

enum ApiFailureType {
  network,
  unauthorized,
  forbidden,
  notFound,
  validation,
  rateLimited,
  server,
  unexpected,
}

/// A failure with a message that is safe to show to the user.
class ApiException implements Exception {
  const ApiException(this.type, this.message, {this.statusCode});

  final ApiFailureType type;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($type, $statusCode): $message';
}

const ApiException unexpectedResponse = ApiException(
  ApiFailureType.unexpected,
  'Unexpected response from the server. Try again.',
);

ApiException apiExceptionFromDio(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const ApiException(
        ApiFailureType.network,
        'Cannot reach DukanOS. Check your internet connection and try again.',
      );
    case DioExceptionType.badResponse:
      return _fromResponse(e.response);
    default:
      return unexpectedResponse;
  }
}

ApiException _fromResponse(Response<dynamic>? response) {
  final status = response?.statusCode ?? 0;
  final body = response?.data;

  if (status == 401) {
    // The interceptor also signs the user out; keep a user-friendly message.
    return ApiException(
      ApiFailureType.unauthorized,
      _serverMessage(body) ?? 'Your session has expired. Sign in again.',
      statusCode: 401,
    );
  }
  if (status == 403) {
    return ApiException(
      ApiFailureType.forbidden,
      _serverMessage(body) ?? 'You do not have permission to do this.',
      statusCode: 403,
    );
  }
  if (status == 404) {
    return ApiException(
      ApiFailureType.notFound,
      _serverMessage(body) ?? 'This item no longer exists.',
      statusCode: 404,
    );
  }
  if (status == 409 || status == 422) {
    return ApiException(
      ApiFailureType.validation,
      _validationMessage(body) ??
          _serverMessage(body) ??
          'Check the details you entered and try again.',
      statusCode: status,
    );
  }
  if (status == 429) {
    return ApiException(
      ApiFailureType.rateLimited,
      _serverMessage(body) ?? 'Too many requests. Wait a moment and try again.',
      statusCode: 429,
    );
  }
  if (status >= 500) {
    return ApiException(
      ApiFailureType.server,
      _serverMessage(body) ?? 'DukanOS is having a problem. Try again shortly.',
      statusCode: status,
    );
  }
  return ApiException(
    ApiFailureType.unexpected,
    _serverMessage(body) ?? unexpectedResponse.message,
    statusCode: status == 0 ? null : status,
  );
}

String? _serverMessage(Object? body) {
  if (body is! Map) return null;
  final message = body['message'];
  if (message is String && message.trim().isNotEmpty) return message.trim();
  return null;
}

/// First field error of a Laravel validation response, else its message.
String? _validationMessage(Object? body) {
  if (body is Map) {
    final errors = body['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty && value.first is String) {
          final first = value.first as String;
          if (first.trim().isNotEmpty) return first.trim();
        }
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
  }
  return _serverMessage(body);
}

/// Runs [run] and converts transport and parsing failures into [ApiException].
Future<T> guardApi<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on DioException catch (e) {
    throw apiExceptionFromDio(e);
  } on ApiException {
    rethrow;
  } on FormatException {
    throw unexpectedResponse;
  } on TypeError {
    throw unexpectedResponse;
  }
}
