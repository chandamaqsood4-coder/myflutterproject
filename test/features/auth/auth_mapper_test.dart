import 'package:dukan_os/features/auth/data/auth_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

const Map<String, dynamic> sampleLoginData = {
  'user': {
    'id': 1,
    'name': 'Admin',
    'email': 'admin@example.com',
    'phone': null,
    'status': 'active',
    'last_login_at': '2026-10-20T10:11:15+00:00',
    'role': {'id': 1, 'name': 'Super Admin', 'slug': 'super_admin'},
    'tenant': null,
    'permissions': ['products.view', 'invoices.create'],
    'created_at': '2026-10-14T10:09:41+00:00',
  },
  'token': 'test-token',
  'token_type': 'Bearer',
};

void main() {
  test('parses the login response data', () {
    final session = authSessionFromJson(sampleLoginData);

    expect(session.token, 'test-token');
    expect(session.tokenType, 'Bearer');
    expect(session.user.id, 1);
    expect(session.user.isActive, isTrue);
    expect(session.user.phone, isNull);
    expect(session.user.tenant, isNull);
    expect(session.user.role?.slug, 'super_admin');
    expect(session.user.hasPermission('products.view'), isTrue);
    expect(session.user.hasPermission('users.manage'), isFalse);
    expect(session.user.lastLoginAt, isNotNull);
  });

  test('throws when the token is missing', () {
    final data = Map<String, dynamic>.from(sampleLoginData)..remove('token');
    expect(() => authSessionFromJson(data), throwsFormatException);
  });
}
