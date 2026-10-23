import 'package:dio/dio.dart';
import 'package:dukan_os/core/network/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _http(int status, Object? body) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: status,
      data: body,
    ),
  );
}

void main() {
  test('401 means the session expired', () {
    final e = apiExceptionFromDio(_http(401, {'message': 'Unauthenticated.'}));
    expect(e.type, ApiFailureType.unauthorized);
  });

  test('422 uses the first field error', () {
    final e = apiExceptionFromDio(
      _http(422, {
        'message': 'The given data was invalid.',
        'errors': {
          'slug': ['The slug has already been taken.'],
        },
      }),
    );
    expect(e.type, ApiFailureType.validation);
    expect(e.message, 'The slug has already been taken.');
  });

  test('403 uses the server message when present', () {
    final e = apiExceptionFromDio(_http(403, {'message': 'Not allowed.'}));
    expect(e.type, ApiFailureType.forbidden);
    expect(e.message, 'Not allowed.');
  });

  test('connection errors are network failures', () {
    final e = apiExceptionFromDio(
      DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      ),
    );
    expect(e.type, ApiFailureType.network);
  });

  test('5xx is a server failure', () {
    expect(apiExceptionFromDio(_http(503, null)).type, ApiFailureType.server);
  });

  test('guardApi converts parsing errors', () {
    expect(
      guardApi<int>(() async => throw const FormatException('bad')),
      throwsA(isA<ApiException>()),
    );
  });
}
