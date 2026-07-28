import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/network/device_models.dart';
import 'package:numi/core/network/network_client.dart';

void main() {
  late AppLanguage originalLanguage;

  setUp(() {
    originalLanguage = AppLanguageState.current;
    AppLanguageState.current = AppLanguage.en;
  });

  tearDown(() {
    AppLanguageState.current = originalLanguage;
  });

  for (final type in <DioExceptionType>[
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  ]) {
    test('$type uses the friendly internet connection message', () async {
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: type,
                  message: 'technical transport error',
                ),
              );
            },
          ),
        );
      final client = NetworkClient(baseUrl: 'https://example.test', dio: dio);

      await expectLater(
        client.getJson('/resource'),
        throwsA(
          isA<NetworkException>().having(
            (error) => error.message,
            'message',
            'Please check your internet connection and try again.',
          ),
        ),
      );
    });
  }

  test('keeps an API validation message unchanged', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<Object?>(
                requestOptions: options,
                statusCode: 422,
                data: const <String, dynamic>{
                  'mmessage': 'The submitted value is invalid.',
                },
              ),
            );
          },
        ),
      );
    final client = NetworkClient(baseUrl: 'https://example.test', dio: dio);

    await expectLater(
      client.getJson('/resource'),
      throwsA(
        isA<NetworkException>().having(
          (error) => error.message,
          'message',
          'The submitted value is invalid.',
        ),
      ),
    );
  });

  test('listDevices posts the request and parses the response', () async {
    String? requestPath;
    Object? requestBody;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestPath = options.path;
            requestBody = options.data;
            handler.resolve(
              Response<Object?>(
                requestOptions: options,
                statusCode: 200,
                data: const <String, dynamic>{
                  'devices': <Map<String, dynamic>>[
                    <String, dynamic>{
                      'device_id': 4,
                      'device_name': 'TECNO SPARK Go 1',
                      'device_uuid': 'UP1A.231005.007',
                      'is_verified': true,
                      'platform': 'UNKNOWN',
                      'status': 'ACTIVE',
                      'user_id': 21,
                    },
                  ],
                  'mstatus': 200,
                  'status': 'Success',
                },
              ),
            );
          },
        ),
      );
    final api = NetworkApi(
      networkClient: NetworkClient(baseUrl: 'https://example.test', dio: dio),
    );

    final response = await api.listDevices(
      const DeviceListRequest(userId: 21, isVerified: true),
    );

    expect(requestPath, '/devices/list');
    expect(requestBody, <String, dynamic>{'user_id': 21, 'is_verified': true});
    expect(response.devices.single.deviceId, 4);
  });
}
