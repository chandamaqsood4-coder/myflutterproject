import '../domain/auth_session.dart';
import '../domain/auth_user.dart';

/// Parses the `data` object of the login response.
/// Throws [FormatException] or [TypeError] if the payload is malformed.
AuthSession authSessionFromJson(Map<String, dynamic> json) {
  final token = json['token'];
  if (token is! String || token.isEmpty) {
    throw const FormatException('Login response has no token.');
  }
  return AuthSession(
    user: _userFromJson(_object(json, 'user')),
    token: token,
    tokenType: (json['token_type'] as String?) ?? 'Bearer',
  );
}

AuthUser _userFromJson(Map<String, dynamic> json) {
  final roleJson = json['role'];
  return AuthUser(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String?,
    status: json['status'] as String,
    lastLoginAt: _date(json['last_login_at']),
    role: roleJson is Map<String, dynamic>
        ? AuthRole(
            id: (roleJson['id'] as num).toInt(),
            name: roleJson['name'] as String,
            slug: roleJson['slug'] as String,
          )
        : null,
    tenant: json['tenant'] as Map<String, dynamic>?,
    permissions: ((json['permissions'] as List<dynamic>?) ?? const [])
        .whereType<String>()
        .toSet(),
    createdAt: _date(json['created_at']),
  );
}

Map<String, dynamic> _object(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Expected an object at "$key".');
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
