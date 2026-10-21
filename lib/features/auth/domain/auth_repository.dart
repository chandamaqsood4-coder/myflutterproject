import 'auth_session.dart';

abstract interface class AuthRepository {
  /// Signs in online. When [rememberMe] is true the session is stored securely
  /// and restored on the next launch. Throws [AuthException].
  Future<AuthSession> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  });

  /// Returns the stored session, or null when there is none.
  Future<AuthSession?> restoreSession();

  /// Clears the stored session.
  Future<void> signOut();
}
