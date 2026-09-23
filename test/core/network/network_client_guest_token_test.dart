import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/api_metadata.dart';
import 'package:numi/core/network/auth_token_store.dart';
import 'package:numi/core/network/network_client.dart';

class _TokenStore implements AuthTokenStore {
  _TokenStore(this.token);

  String? token;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String value) async {
    token = value;
  }

  @override
  Future<void> clearToken() async {
    token = null;
  }
}

class _MetadataProvider implements ApiMetadataProvider {
  @override
  Future<Map<String, Object>> buildMetadata() async => <String, Object>{};
}

class _ResponseAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    '{"mstatus":200}',
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      if (options.path == '/users/create/guest')
        'X-Auth-Token': <String>['guest-jwt'],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'guest responses and requests use guest_token, not auth_token',
    () async {
      final authToken = _TokenStore(null);
      final guestToken = _TokenStore(null);
      final requests = <RequestOptions>[];
      final dio = Dio()..httpClientAdapter = _ResponseAdapter();
      final client = NetworkClient(
        baseUrl: 'https://example.test',
        dio: dio,
        authTokenStore: authToken,
        guestTokenStore: guestToken,
        metadataProvider: _MetadataProvider(),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.next(options);
          },
        ),
      );

      await client.postJson(
        '/users/create/guest',
        const <String, dynamic>{},
        useGuestToken: true,
      );
      expect(guestToken.token, 'guest-jwt');
      expect(authToken.token, isNull);
      expect(await client.hasAuthToken(), isFalse);

      await client.postJson('/profiles/list', const <String, dynamic>{
        'uid': 42,
      }, useGuestToken: true);
      await client.postJson('/auth/login-resume', const <String, dynamic>{});

      final guestMetadata = Map<String, dynamic>.from(
        (requests[1].data as Map<String, dynamic>)['metadata'] as Map,
      );
      final loginMetadata = Map<String, dynamic>.from(
        (requests[2].data as Map<String, dynamic>)['metadata'] as Map,
      );
      expect(guestMetadata['authorization'], 'Bearer guest-jwt');
      expect(loginMetadata['authorization'], '');
    },
  );

  test('moves a legacy guest token out of auth_token', () async {
    final authToken = _TokenStore('legacy-guest-jwt');
    final guestToken = _TokenStore(null);
    final client = NetworkClient(
      baseUrl: 'https://example.test',
      authTokenStore: authToken,
      guestTokenStore: guestToken,
      metadataProvider: _MetadataProvider(),
    );

    await client.moveAuthTokenToGuest();

    expect(authToken.token, isNull);
    expect(guestToken.token, 'legacy-guest-jwt');
    expect(await client.hasAuthToken(), isFalse);
  });
}
