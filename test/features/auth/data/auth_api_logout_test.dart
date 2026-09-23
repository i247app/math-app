import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/api_metadata.dart';
import 'package:numi/core/network/auth_token_store.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/auth/data/auth_api.dart';

void main() {
  test(
    'logout posts authenticated metadata before clearing the token',
    () async {
      final tokenStore = _TestTokenStore('session-token');
      String? method;
      String? path;
      Map<String, dynamic>? body;
      final dio = Dio();
      final api = AuthApi(
        networkClient: NetworkClient(
          baseUrl: 'https://example.test',
          dio: dio,
          authTokenStore: tokenStore,
          metadataProvider: _TestMetadataProvider(),
        ),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            method = options.method;
            path = options.path;
            body = Map<String, dynamic>.from(options.data as Map);
            handler.resolve(
              Response<Object?>(
                requestOptions: options,
                statusCode: 200,
                data: const <String, dynamic>{'mstatus': 200},
              ),
            );
          },
        ),
      );

      await api.logout();

      expect(method, 'POST');
      expect(path, '/auth/logout');
      expect(body?.keys, contains('metadata'));
      expect(
        (body?['metadata'] as Map<String, Object>)['authorization'],
        'Bearer session-token',
      );
      expect(tokenStore.token, isNull);
      expect(tokenStore.clearCount, 1);
    },
  );

  test('logout clears the token when the server request fails', () async {
    final tokenStore = _TestTokenStore('session-token');
    final dio = Dio();
    final api = AuthApi(
      networkClient: NetworkClient(
        baseUrl: 'https://example.test',
        dio: dio,
        authTokenStore: tokenStore,
        metadataProvider: _TestMetadataProvider(),
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<Object?>(
              requestOptions: options,
              statusCode: 503,
              data: const <String, dynamic>{'mmessage': 'Unavailable'},
            ),
          );
        },
      ),
    );

    await api.logout();

    expect(tokenStore.token, isNull);
    expect(tokenStore.clearCount, 1);
  });
}

class _TestTokenStore implements AuthTokenStore {
  _TestTokenStore(this.token);

  String? token;
  int clearCount = 0;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String token) async => this.token = token;

  @override
  Future<void> clearToken() async {
    token = null;
    clearCount++;
  }
}

class _TestMetadataProvider implements ApiMetadataProvider {
  @override
  Future<Map<String, Object>> buildMetadata() async => <String, Object>{
    'device_uuid': 'test-device',
  };
}
