import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../core/config/api_config.dart';

class PhoneCheckResult {
  const PhoneCheckResult({
    required this.phone,
    required this.exists,
    this.userId,
  });

  final String phone;
  final bool exists;
  final String? userId;
}

class SendOtpResult {
  const SendOtpResult({
    required this.expiresIn,
    this.otpId,
    this.otpCode,
    this.purpose,
    this.expiresAt,
    this.message,
  });

  final String? otpId;
  final String? otpCode;
  final String? purpose;
  final int expiresIn;
  final String? expiresAt;
  final String? message;
}

class LoginUser {
  const LoginUser({
    required this.id,
    this.email,
    this.name,
    this.phone,
    this.avatarUrl,
    this.role,
  });

  final String id;
  final String? email;
  final String? name;
  final String? phone;
  final String? avatarUrl;
  final String? role;
}

class VerifyOtpResult {
  const VerifyOtpResult({
    required this.isValid,
    this.message,
    this.user,
  });

  final bool isValid;
  final String? message;
  final LoginUser? user;
}

class OtpAuthException implements Exception {
  const OtpAuthException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class OtpAuthService {
  Future<PhoneCheckResult> checkPhone(String phone);

  Future<SendOtpResult> sendLoginOtp(String phone);

  Future<VerifyOtpResult> verifyLoginOtp({
    required String phone,
    required String otpCode,
  });
}

class OtpAuthApi implements OtpAuthService {
  OtpAuthApi({
    String? baseUrl,
    HttpClient? httpClient,
  })  : _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _httpClient = httpClient ?? HttpClient();

  final String _baseUrl;
  final HttpClient _httpClient;

  @override
  Future<PhoneCheckResult> checkPhone(String phone) async {
    final json = await _post('/auth/phone/check', {'phone': phone});

    return PhoneCheckResult(
      phone: json['phone'] as String? ?? phone,
      exists: json['exists'] == true,
      userId: json['user_id'] as String?,
    );
  }

  @override
  Future<SendOtpResult> sendLoginOtp(String phone) async {
    final json = await _post('/auth/otp/send', {
      'phone_number': phone,
      'purpose': 'login',
      'channel': 'sms',
    });

    return SendOtpResult(
      otpId: json['otp_id'] as String?,
      otpCode: _readString(json['otp_code']),
      purpose: json['purpose'] as String? ?? 'login',
      expiresIn: json['expires_in'] as int? ?? 180,
      expiresAt: json['expires_at'] as String?,
      message: json['message'] as String?,
    );
  }

  @override
  Future<VerifyOtpResult> verifyLoginOtp({
    required String phone,
    required String otpCode,
  }) async {
    final json = await _post(
      '/auth/otp/verify',
      {
        'phone_number': phone,
        'purpose': 'login',
        'otp_code': otpCode,
      },
      headers: {
        'Device-UUID': 'numi-flutter-${Platform.operatingSystem}',
        'Device-Name': 'NUMI ${Platform.operatingSystem}',
      },
    );

    final login = json['login'];
    final user = login is Map<String, dynamic> ? login['user'] : null;

    return VerifyOtpResult(
      isValid: json['is_valid'] == true,
      message: json['message'] as String?,
      user: user is Map<String, dynamic>
          ? LoginUser(
              id: user['id'] as String? ?? '',
              email: user['email'] as String?,
              name: user['name'] as String?,
              phone: user['phone'] as String?,
              avatarUrl: user['avatar_url'] as String?,
              role: user['role'] as String?,
            )
          : null,
    );
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, Object?> body, {
    Map<String, String> headers = const {},
  }) async {
    if (_baseUrl.trim().isEmpty) {
      throw const OtpAuthException(
        'Chưa cấu hình API_BASE_URL cho OTP API.',
      );
    }

    final normalizedBaseUrl = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final uri = Uri.parse('$normalizedBaseUrl$path');
    final HttpClientRequest request;
    try {
      request = await _httpClient.postUrl(uri).timeout(
            const Duration(seconds: 15),
          );
    } on TimeoutException {
      throw const OtpAuthException('Kết nối API quá thời gian chờ.');
    } on SocketException catch (error) {
      throw OtpAuthException(
        'Không kết nối được API: ${error.message}',
      );
    }

    request.headers.contentType = ContentType.json;
    for (final entry in headers.entries) {
      request.headers.set(entry.key, entry.value);
    }

    request.write(jsonEncode(body));

    final HttpClientResponse response;
    try {
      response = await request.close().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const OtpAuthException('API phản hồi quá thời gian chờ.');
    } on SocketException catch (error) {
      throw OtpAuthException(
        'Không kết nối được API: ${error.message}',
      );
    }

    final responseBody = await response.transform(utf8.decoder).join();
    final Object? decoded;
    try {
      decoded = jsonDecode(responseBody);
    } on FormatException {
      throw const OtpAuthException('Response từ server không phải JSON.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const OtpAuthException('Response từ server không hợp lệ.');
    }

    final status = decoded['mstatus'] as int?;
    if (status != 200) {
      throw OtpAuthException(
        decoded['mmessage'] as String? ??
            decoded['error'] as String? ??
            'Request failed.',
        status: status,
      );
    }

    return decoded;
  }

  String? _readString(Object? value) {
    if (value == null) {
      return null;
    }

    return value.toString();
  }
}
