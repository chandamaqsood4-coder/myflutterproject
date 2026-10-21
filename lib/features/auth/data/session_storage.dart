import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the login `data` object in the OS secure store
/// (Windows: DPAPI-protected, Linux: libsecret keyring).
class SessionStorage {
  SessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _key = 'auth_session_v1';

  final FlutterSecureStorage _storage;

  Future<void> save(Map<String, dynamic> data) =>
      _storage.write(key: _key, value: jsonEncode(data));

  Future<Map<String, dynamic>?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  Future<void> clear() => _storage.delete(key: _key);
}
