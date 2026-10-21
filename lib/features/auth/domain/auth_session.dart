import 'auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.token,
    this.tokenType = 'Bearer',
  });

  final AuthUser user;
  final String token;
  final String tokenType;
}
