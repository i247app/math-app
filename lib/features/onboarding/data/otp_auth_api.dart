import '../../../core/config/api_config.dart';
import '../../../core/network/auth_models.dart';
import '../../../core/network/network_client.dart';

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

class AuthPhoneLookupResult {
  const AuthPhoneLookupResult({
    required this.phone,
    required this.exists,
    this.user,
  });

  final String phone;
  final bool exists;
  final LoginUser? user;
}

extension on AuthUser {
  LoginUser toLoginUser({String? fallbackPhone}) {
    return LoginUser(
      id: userId ?? id ?? '',
      email: email,
      name: name,
      phone: phone ?? fallbackPhone,
      avatarUrl: avatarUrl,
      role: role,
    );
  }
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

  Future<AuthPhoneLookupResult> checkAuthPhone(String phone);

  Future<LoginUser> loginWithPhone(String phone);

  Future<SendOtpResult> sendLoginOtp(String phone);

  Future<VerifyOtpResult> verifyLoginOtp({
    required String phone,
    required String otpCode,
  });
}

class OtpAuthApi implements OtpAuthService {
  OtpAuthApi({
    String? baseUrl,
    NetworkApi? networkApi,
  }) : _networkApi =
            networkApi ?? NetworkApi(baseUrl: baseUrl ?? ApiConfig.baseUrl);

  static const _localOtpCode = '1234';

  final NetworkApi _networkApi;
  final Map<String, String> _pendingOtpCodes = {};
  final Map<String, LoginUser> _loginUsers = {};

  @override
  Future<PhoneCheckResult> checkPhone(String phone) async {
    return PhoneCheckResult(
      phone: phone,
      exists: true,
      userId: _loginUsers[phone]?.id,
    );
  }

  @override
  Future<AuthPhoneLookupResult> checkAuthPhone(String phone) async {
    final AuthResponse response;
    try {
      response = await _networkApi.login(LoginRequest(phone: phone));
    } on NetworkException catch (error) {
      if (error.status == 202 || error.status == 4006) {
        return AuthPhoneLookupResult(phone: phone, exists: false);
      }

      throw OtpAuthException(error.message, status: error.status);
    }

    final user = response.user?.toLoginUser(fallbackPhone: phone);
    if (user == null) {
      throw const OtpAuthException('Response login thiếu thông tin user.');
    }

    _loginUsers[phone] = user;
    return AuthPhoneLookupResult(phone: phone, exists: true, user: user);
  }

  @override
  Future<SendOtpResult> sendLoginOtp(String phone) async {
    final AuthResponse response;
    try {
      response = await _networkApi.authOtp(LoginRequest(phone: phone));
    } on NetworkException catch (error) {
      throw OtpAuthException(error.message, status: error.status);
    }

    final user = response.user?.toLoginUser(fallbackPhone: phone);
    if (user == null) {
      throw const OtpAuthException('Response OTP thiếu thông tin user.');
    }

    final otpCode = response.otpCode ?? _localOtpCode;
    _loginUsers[phone] = user;
    _pendingOtpCodes[phone] = otpCode;

    return SendOtpResult(
      otpCode: otpCode,
      purpose: 'login',
      expiresIn: 180,
      message: response.status,
    );
  }

  @override
  Future<LoginUser> loginWithPhone(String phone) async {
    final cachedUser = _loginUsers[phone];
    if (cachedUser != null) {
      return cachedUser;
    }

    final result = await checkAuthPhone(phone);
    final user = result.user;
    if (!result.exists || user == null) {
      throw const OtpAuthException('User not found', status: 202);
    }

    return user;
  }

  @override
  Future<VerifyOtpResult> verifyLoginOtp({
    required String phone,
    required String otpCode,
  }) async {
    final expectedOtp = _pendingOtpCodes[phone];
    final isValid = expectedOtp != null && expectedOtp == otpCode;
    if (isValid) {
      _pendingOtpCodes.remove(phone);
    }

    return VerifyOtpResult(
      isValid: isValid,
      message: isValid ? 'Success' : 'OTP không hợp lệ.',
      user: isValid
          ? _loginUsers[phone] ?? LoginUser(id: '', phone: phone)
          : null,
    );
  }
}
