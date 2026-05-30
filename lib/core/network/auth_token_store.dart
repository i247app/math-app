import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthTokenStore {
  Future<String?> readToken();

  Future<void> writeToken(String token);

  Future<void> clearToken();
}

class SecureAuthTokenStore implements AuthTokenStore {
  const SecureAuthTokenStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
