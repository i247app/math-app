import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/api_metadata.dart';
import 'package:numi/core/network/auth_token_store.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/auth/data/auth_api.dart';

void main() {
  test(
    'check identifier posts email and metadata and preserves raw response',
    () async {
      final response = <String, dynamic>{
        'mstatus': 200,
        'status': 'Success',
        'is_available': true,
        'email_otp_enable': true,
        'phone_otp_enable': false,
      };
      final api = _buildApi(
        response,
        onRequest: (options) {
          expect(options.method, 'POST');
          expect(options.path, '/users/identifier-available');
          final body = options.data as Map;
          expect(body['identifier'], 'eric@gmail.com');
          expect((body['metadata'] as Map)['device_uuid'], 'test-device');
          expect(body.containsKey('login_name'), isFalse);
        },
      );

      expect(await api.checkIdentifier(' eric@gmail.com '), response);
    },
  );

  test(
    'check identifier preserves non-200 API status for signup handling',
    () async {
      final response = <String, dynamic>{
        'mstatus': 4206,
        'mmessage': 'Already registered',
      };
      final api = _buildApi(response, httpStatus: 409);

      expect(await api.checkIdentifier('eric@gmail.com'), response);
    },
  );
  test('check identifier sends a normalized phone number', () async {
    final response = <String, dynamic>{
      'mstatus': 200,
      'is_available': true,
      'email_otp_enable': true,
      'phone_otp_enable': false,
    };
    final api = _buildApi(
      response,
      onRequest: (options) {
        expect(options.path, '/users/identifier-available');
        expect((options.data as Map)['identifier'], '+84702465814');
      },
    );

    expect(await api.checkIdentifier(' +84702465814 '), response);
  });
}

AuthApi _buildApi(
  Map<String, dynamic> response, {
  void Function(RequestOptions)? onRequest,
  int httpStatus = 200,
}) {
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
            statusCode: httpStatus,
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
