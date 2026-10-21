class AuthRole {
  const AuthRole({required this.id, required this.name, required this.slug});

  final int id;
  final String name;
  final String slug;
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.permissions,
    required this.createdAt,
    this.phone,
    this.lastLoginAt,
    this.role,
    this.tenant,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String status;
  final DateTime? lastLoginAt;
  final AuthRole? role;

  /// Shape not confirmed (null for the super admin). Keep raw until the API
  /// documents it.
  final Map<String, dynamic>? tenant;

  final Set<String> permissions;
  final DateTime? createdAt;

  bool get isActive => status == 'active';

  bool hasPermission(String permission) => permissions.contains(permission);
}
