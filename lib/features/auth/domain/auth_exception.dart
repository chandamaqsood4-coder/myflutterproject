enum AuthFailureType {
  invalidCredentials,
  inactiveAccount,
  rateLimited,
  network,
  server,
  unexpected,
}

/// A failure with a message that is safe to show to the user.
class AuthException implements Exception {
  const AuthException(this.type, this.message);

  final AuthFailureType type;
  final String message;

  @override
  String toString() => 'AuthException($type): $message';
}
