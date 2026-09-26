import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/api_metadata.dart';
import 'package:numi/core/network/auth_token_store.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/features/auth/data/auth_exception.dart';

void main() {
  test(
    'check identifier posts email and metadata and preserves raw response',
    () async {
      final response = <String, dynamic>{
        'mstatus': 200,
        'status': 'Success',
        'user': <String, dynamic>{
          'create_dt': '2026-09-24T17:35:01.599991Z',
          'email': 'eric@gmail.com',
          'id': 43,
          'identity_code': 'USER',
          'is_email_verified': true,
          'modify_dt': '2026-09-24T17:35:01.599991Z',
          'name': 'Kenny Real',
          'role': 'PARENT',
          'uid': 22,
        },
      };
      final api = _buildApi(response, (options) {
        expect(options.method, 'POST');
        expect(options.path, '/users/check-identifier');
        final body = options.data as Map;
        expect(body['identifier'], 'eric@gmail.com');
        expect((body['metadata'] as Map)['device_uuid'], 'test-device');
        expect(body.containsKey('login_name'), isFalse);
      });

      expect(await api.checkIdentifier(' eric@gmail.com '), response);
    },
  );

  test('check identifier exposes API errors as AuthException', () async {
    final api = _buildApi(<String, dynamic>{
      'mstatus': 4206,
      'mmessage': 'User not found',
    });

    await expectLater(
      api.checkIdentifier('eric@gmail.com'),
      throwsA(
        isA<AuthException>()
            .having((error) => error.status, 'status', 4206)
            .having((error) => error.message, 'message', 'User not found'),
      ),
    );
  });
}

AuthApi _buildApi(
  Map<String, dynamic> response, [
  void Function(RequestOptions)? onRequest,
]) {
  final dio = Dio();
  final api = AuthApi(
    networkClient: NetworkClient(
      baseUrl: 'https://example.test',
      dio: dio,
      authTokenStore: _TestTokenStore(),
      metadataProvider: _TestMetadataProvider(),
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        onRequest?.call(options);
        handler.resolve(
          Response<Object?>(
            requestOptions: options,
            statusCode: 200,
            data: response,
          ),
        );
      },
    ),
  );
  return api;
}

class _TestTokenStore implements AuthTokenStore {
  @override
  Future<String?> readToken() async => null;

  @override
  Future<void> writeToken(String token) async {}

  @override
  Future<void> clearToken() async {}
}

class _TestMetadataProvider implements ApiMetadataProvider {
  @override
  Future<Map<String, Object>> buildMetadata() async => <String, Object>{
    'device_uuid': 'test-device',
  };
}
