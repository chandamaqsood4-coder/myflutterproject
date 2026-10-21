import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/auth_remote_data_source.dart';
import '../../data/auth_repository_impl.dart';
import '../../data/session_storage.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_session.dart';

/// Shared HTTP client. Move to core/ when a second feature needs it.
final dioProvider = Provider<Dio>((ref) {
  final dio = createApiClient(
    tokenReader: () {
      final session = ref.read(sessionProvider);
      return session is AsyncData<AuthSession?> ? session.value?.token : null;
    },
  );
  ref.onDispose(dio.close);
  return dio;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: AuthRemoteDataSource(ref.watch(dioProvider)),
    storage: SessionStorage(),
  );
});

/// The signed-in session. Loads the stored session once at startup.
final sessionProvider = AsyncNotifierProvider<SessionNotifier, AuthSession?>(
  SessionNotifier.new,
);

class SessionNotifier extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() =>
      ref.read(authRepositoryProvider).restoreSession();

  void setSession(AuthSession session) => state = AsyncData(session);

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}

/// Runs the sign-in action and exposes its loading and error state.
final loginControllerProvider = AsyncNotifierProvider<LoginController, void>(
  LoginController.new,
);

class LoginController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password, rememberMe: rememberMe);
      ref.read(sessionProvider.notifier).setSession(session);
    });
  }
}
