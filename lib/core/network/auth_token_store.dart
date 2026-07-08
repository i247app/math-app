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

/// Keeps the auth token in memory while using secure storage for persistence.
///
/// The first read is shared by concurrent callers. Subsequent requests avoid
/// crossing the platform channel, and repeated writes of the same token are
/// skipped.
class CachedAuthTokenStore implements AuthTokenStore {
  CachedAuthTokenStore({AuthTokenStore? persistentStore})
    : _persistentStore = persistentStore ?? const SecureAuthTokenStore();

  static final CachedAuthTokenStore instance = CachedAuthTokenStore();

  final AuthTokenStore _persistentStore;
  String? _cachedToken;
  bool _hasLoaded = false;
  Future<String?>? _pendingRead;
  int _generation = 0;

  @override
  Future<String?> readToken() {
    if (_hasLoaded) {
      return Future<String?>.value(_cachedToken);
    }

    return _pendingRead ??= _loadToken();
  }

  Future<String?> _loadToken() async {
    final generation = _generation;
    try {
      final token = await _persistentStore.readToken();
      if (generation == _generation) {
        _cachedToken = token;
        _hasLoaded = true;
      }
      return _cachedToken;
    } finally {
      if (generation == _generation) {
        _pendingRead = null;
      }
    }
  }

  @override
  Future<void> writeToken(String token) async {
    if (_hasLoaded && _cachedToken == token) {
      return;
    }

    _generation++;
    _pendingRead = null;
    _cachedToken = token;
    _hasLoaded = true;
    await _persistentStore.writeToken(token);
  }

  @override
  Future<void> clearToken() async {
    _generation++;
    _pendingRead = null;
    _cachedToken = null;
    _hasLoaded = true;
    await _persistentStore.clearToken();
  }
}
