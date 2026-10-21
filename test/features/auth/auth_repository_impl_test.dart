import 'package:dio/dio.dart';
import 'package:dukan_os/features/auth/data/auth_remote_data_source.dart';
import 'package:dukan_os/features/auth/data/auth_repository_impl.dart';
import 'package:dukan_os/features/auth/data/session_storage.dart';
import 'package:dukan_os/features/auth/domain/auth_exception.dart';
import 'package:flutter_test/flutter_test.dart';

import 'auth_mapper_test.dart' show sampleLoginData;

class _FakeRemote implements AuthRemoteDataSource {
  _FakeRemote(this._handler);

  final Future<Map<String, dynamic>> Function() _handler;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) => _handler();
}

class _FakeStorage implements SessionStorage {
  Map<String, dynamic>? saved;

  @override
  Future<void> save(Map<String, dynamic> data) async => saved = data;

  @override
  Future<Map<String, dynamic>?> read() async => saved;

  @override
  Future<void> clear() async => saved = null;
}

DioException _http(int status, Object? body) {
  final options = RequestOptions(path: '/auth/login');
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

AuthRepositoryImpl _repo(_FakeRemote remote, _FakeStorage storage) =>
    AuthRepositoryImpl(remote: remote, storage: storage);

void main() {
  late _FakeStorage storage;

  setUp(() => storage = _FakeStorage());

  test('signs in and stores the session when rememberMe is true', () async {
    final repo = _repo(_FakeRemote(() async => sampleLoginData), storage);

    final session = await repo.signIn(
      email: 'a@b.com',
      password: 'secret',
      rememberMe: true,
    );

    expect(session.user.email, 'admin@example.com');
    expect(storage.saved, isNotNull);
  });

  test('does not store the session when rememberMe is false', () async {
    storage.saved = sampleLoginData;
    final repo = _repo(_FakeRemote(() async => sampleLoginData), storage);

    await repo.signIn(email: 'a@b.com', password: 'secret', rememberMe: false);

    expect(storage.saved, isNull);
  });

  test('rejects an inactive account', () async {
    final data = {
      ...sampleLoginData,
      'user': {
        ...(sampleLoginData['user'] as Map<String, dynamic>),
        'status': 'suspended',
      },
    };
    final repo = _repo(_FakeRemote(() async => data), storage);

    expect(
      () => repo.signIn(email: 'a@b.com', password: 'x', rememberMe: true),
      throwsA(
        isA<AuthException>().having(
          (e) => e.type,
          'type',
          AuthFailureType.inactiveAccount,
        ),
      ),
    );
    expect(storage.saved, isNull);
  });

  test('maps 401 to invalid credentials using the server message', () async {
    final repo = _repo(
      _FakeRemote(() async => throw _http(401, {'message': 'Wrong login.'})),
      storage,
    );

    expect(
      () => repo.signIn(email: 'a@b.com', password: 'x', rememberMe: true),
      throwsA(
        isA<AuthException>()
            .having((e) => e.type, 'type', AuthFailureType.invalidCredentials)
            .having((e) => e.message, 'message', 'Wrong login.'),
      ),
    );
  });

  test('maps connection errors to a network failure', () async {
    final repo = _repo(
      _FakeRemote(
        () async => throw DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          type: DioExceptionType.connectionError,
        ),
      ),
      storage,
    );

    expect(
      () => repo.signIn(email: 'a@b.com', password: 'x', rememberMe: true),
      throwsA(
        isA<AuthException>().having(
          (e) => e.type,
          'type',
          AuthFailureType.network,
        ),
      ),
    );
  });

  test('restoreSession returns null when nothing is stored', () async {
    final repo = _repo(_FakeRemote(() async => sampleLoginData), storage);
    expect(await repo.restoreSession(), isNull);
  });

  test('restoreSession returns the stored session', () async {
    storage.saved = sampleLoginData;
    final repo = _repo(_FakeRemote(() async => sampleLoginData), storage);

    final session = await repo.restoreSession();

    expect(session?.token, 'test-token');
  });
}
