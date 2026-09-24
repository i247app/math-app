import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/features/auth/data/auth_exception.dart';
import 'package:numi/features/auth/models/auth_models.dart';

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

  test('sendOtp skips blank error fields for a logical API error', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<Object?>(
                requestOptions: options,
                statusCode: 200,
                data: const <String, dynamic>{
                  'mstatus': 429,
                  'mmessage': '   ',
                  'debug': 'OTP request limit reached.',
                  'status': 'Error',
                },
              ),
            );
          },
        ),
      );
    final api = AuthApi(
      networkClient: NetworkClient(baseUrl: 'https://example.test', dio: dio),
    );

    await expectLater(
      api.sendOtp(loginName: 'learner@example.com', kind: AuthOtpKind.signup),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'OTP request limit reached.',
        ),
      ),
    );
  });

  test('signup uses a localized fallback for a blank API error', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<Object?>(
                requestOptions: options,
                statusCode: 200,
                data: const <String, dynamic>{
                  'mstatus': 422,
                  'mmessage': '   ',
                  'debug': '',
                  'status': ' ',
                },
              ),
            );
          },
        ),
      );
    final api = AuthApi(
      networkClient: NetworkClient(baseUrl: 'https://example.test', dio: dio),
    );

    await expectLater(
      api.signupWithEmail(
        email: 'learner@example.com',
        name: 'Learner',
        role: 'STUDENT',
      ),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'Invalid server response.',
        ),
      ),
    );
  });

  test('users/create sends email and omits phone', () async {
    String? requestPath;
    Map<String, String>? fields;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestPath = options.path;
            fields = Map<String, String>.fromEntries(
              (options.data as FormData).fields,
            );
            handler.resolve(
              Response<Object?>(
                requestOptions: options,
                statusCode: 200,
                data: const <String, dynamic>{
                  'mstatus': 200,
                  'user': <String, dynamic>{
                    'uid': 7,
                    'email': 'learner@example.com',
                  },
                },
              ),
            );
          },
        ),
      );
    final api = AuthApi(
      networkClient: NetworkClient(baseUrl: 'https://example.test', dio: dio),
    );

    final user = await api.signupWithEmail(
      email: 'learner@example.com',
      name: 'Learner',
      role: 'STUDENT',
    );

    expect(requestPath, '/users/create');
    expect(fields, <String, String>{
      'email': 'learner@example.com',
      'name': 'Learner',
      'role': 'STUDENT',
    });
    expect(user.email, 'learner@example.com');
    expect(user.phone, isNull);
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
                      'uid': 21,
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
    final api = AuthApi(
      networkClient: NetworkClient(baseUrl: 'https://example.test', dio: dio),
    );

    final response = await api.listTrustedDevices(userId: 21);

    expect(requestPath, '/devices/list');
    expect(requestBody, <String, dynamic>{'uid': 21, 'is_verified': true});
    expect(response.single.deviceId, 4);
  });

  test('sendOtp posts the selected trusted device for login 2FA', () async {
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
                  'expires_at': '2026-07-28T09:24:21.275751Z',
                  'mstatus': 200,
                  'otp_code': '',
                  'otp_type': 'LOGIN_2FA',
                  'status': 'Success',
                },
              ),
            );
          },
        ),
      );
    final api = AuthApi(
      networkClient: NetworkClient(baseUrl: 'https://example.test', dio: dio),
    );

    await api.sendOtp(
      loginName: '+84905666666',
      kind: AuthOtpKind.login,
      userId: 21,
      targetDeviceId: 4,
    );

    expect(requestPath, '/otps/send');
    expect(requestBody, <String, dynamic>{
      'otp_type': 'LOGIN_2FA',
      'identifier': '+84905666666',
      'uid': 21,
      'target_device_id': 4,
    });
  });
}
