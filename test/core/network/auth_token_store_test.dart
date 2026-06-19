import 'package:flutter_test/flutter_test.dart';
import 'package:numi_flutter/core/network/auth_token_store.dart';

void main() {
  group('CachedAuthTokenStore', () {
    test('shares the initial persistent read and caches its result', () async {
      final persistentStore = _FakeAuthTokenStore(token: 'stored-token');
      final store = CachedAuthTokenStore(persistentStore: persistentStore);

      final firstRead = store.readToken();
      final secondRead = store.readToken();

      expect(await Future.wait([firstRead, secondRead]), [
        'stored-token',
        'stored-token',
      ]);
      expect(persistentStore.readCount, 1);

      expect(await store.readToken(), 'stored-token');
      expect(persistentStore.readCount, 1);
    });

    test('updates memory and skips repeated persistent writes', () async {
      final persistentStore = _FakeAuthTokenStore(token: 'old-token');
      final store = CachedAuthTokenStore(persistentStore: persistentStore);

      expect(await store.readToken(), 'old-token');
      await store.writeToken('new-token');
      await store.writeToken('new-token');

      expect(await store.readToken(), 'new-token');
      expect(persistentStore.token, 'new-token');
      expect(persistentStore.writeCount, 1);
    });

    test('clears both memory and persistent storage', () async {
      final persistentStore = _FakeAuthTokenStore(token: 'stored-token');
      final store = CachedAuthTokenStore(persistentStore: persistentStore);

      expect(await store.readToken(), 'stored-token');
      await store.clearToken();

      expect(await store.readToken(), isNull);
      expect(persistentStore.token, isNull);
      expect(persistentStore.clearCount, 1);
      expect(persistentStore.readCount, 1);
    });
  });
}

class _FakeAuthTokenStore implements AuthTokenStore {
  _FakeAuthTokenStore({this.token});

  String? token;
  int readCount = 0;
  int writeCount = 0;
  int clearCount = 0;

  @override
  Future<String?> readToken() async {
    readCount++;
    await Future<void>.delayed(Duration.zero);
    return token;
  }

  @override
  Future<void> writeToken(String token) async {
    writeCount++;
    this.token = token;
  }

  @override
  Future<void> clearToken() async {
    clearCount++;
    token = null;
  }
}
