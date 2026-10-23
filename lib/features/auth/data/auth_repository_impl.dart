import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../domain/auth_exception.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import 'auth_mapper.dart';
import 'auth_remote_data_source.dart';
import 'session_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final SessionStorage _storage;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final Map<String, dynamic> data;
    try {
      data = await _remote.login(email: email, password: password);
    } on DioException catch (e) {
      throw _fromDio(e);
    } on FormatException {
      throw _unexpected;
    } on TypeError {
      throw _unexpected;
    }

    final AuthSession session;
    try {
      session = authSessionFromJson(data);
    } on FormatException {
      throw _unexpected;
    } on TypeError {
      throw _unexpected;
    }

    if (!session.user.isActive) {
      throw const AuthException(
        AuthFailureType.inactiveAccount,
        'This account is not active. Contact your administrator.',
      );
    }

    await _persist(data, rememberMe: rememberMe);
    return session;
  }

  @override
  Future<AuthSession?> restoreSession() async {
    try {
      final data = await _storage.read();
      if (data == null) return null;
      final session = authSessionFromJson(data);
      return session.user.isActive ? session : null;
    } catch (e) {
      // Corrupt or unreadable store: start signed out.
      debugPrint('Could not restore session: $e');
      await _safeClear();
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    // TODO: also revoke the token on the server once the logout endpoint in
    // docs/api.md is confirmed. Until then the token stays valid server-side.
    await _safeClear();
  }

  Future<void> _persist(
    Map<String, dynamic> data, {
    required bool rememberMe,
  }) async {
    try {
      if (rememberMe) {
        await _storage.save(data);
      } else {
        await _storage.clear();
      }
    } catch (e) {
      // Secure storage unavailable: the session still works until app exit.
      debugPrint('Could not update stored session: $e');
    }
  }

  Future<void> _safeClear() async {
    try {
      await _storage.clear();
    } catch (e) {
      debugPrint('Could not clear stored session: $e');
    }
  }

  static const AuthException _unexpected = AuthException(
    AuthFailureType.unexpected,
    'Unexpected response from the server. Try again.',
  );

  AuthException _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const AuthException(
          AuthFailureType.network,
          'Cannot reach DukanOS. Check your internet connection and try again.',
        );
      case DioExceptionType.badResponse:
        return _fromResponse(e.response);
      default:
        return _unexpected;
    }
  }

  AuthException _fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode ?? 0;
    final serverMessage = _serverMessage(response?.data);

    if (status == 401 || status == 422) {
      return AuthException(
        AuthFailureType.invalidCredentials,
        serverMessage ?? 'Incorrect email or password.',
      );
    }
    if (status == 403) {
      return AuthException(
        AuthFailureType.inactiveAccount,
        serverMessage ?? 'Your account does not have access.',
      );
    }
    if (status == 429) {
      return const AuthException(
        AuthFailureType.rateLimited,
        'Too many attempts. Wait a minute and try again.',
      );
    }
    if (status >= 500) {
      return const AuthException(
        AuthFailureType.server,
        'DukanOS is having a problem. Try again shortly.',
      );
    }
    return _unexpected;
  }

  String? _serverMessage(Object? body) {
    if (body is! Map) return null;
    final message = body['message'];
    return message is String && message.isNotEmpty ? message : null;
  }
}
