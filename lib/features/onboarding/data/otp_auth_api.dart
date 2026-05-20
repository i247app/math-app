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
    this.otpCode,
    this.purpose,
    this.expiresIn,
    this.message,
  });

  final String phone;
  final bool exists;
  final LoginUser? user;
  final String? otpCode;
  final String? purpose;
  final int? expiresIn;
  final String? message;
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

  Future<LoginUser?> restoreSession();

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

  static const _loginOtpType = 'LOGIN_2FA';

  final NetworkApi _networkApi;
  final Map<String, LoginUser> _loginUsers = {};

  @override
  Future<LoginUser?> restoreSession() async {
    if (!await _networkApi.hasAuthToken()) {
      return null;
    }

    try {
      return (await _networkApi.getCurrentUser()).toLoginUser();
    } on NetworkException catch (error) {
      if (_isUnauthorized(error.status)) {
        await _networkApi.clearAuthToken();
      }

      return null;
    }
  }

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
      response = await _networkApi.authOtp(LoginRequest(phone: phone));
    } on NetworkException catch (error) {
      if (error.status == 202) {
        _loginUsers.remove(phone);
        return AuthPhoneLookupResult(phone: phone, exists: false);
      }

      throw OtpAuthException(error.message, status: error.status);
    }

    final user = response.user?.toLoginUser(fallbackPhone: phone);
    if (user == null) {
      throw const OtpAuthException('Response OTP thiếu thông tin user.');
    }

    _loginUsers[phone] = user;
    return AuthPhoneLookupResult(
      phone: phone,
      exists: true,
      user: user,
      otpCode: response.otpCode,
      purpose: 'login',
      expiresIn: 180,
      message: response.status,
    );
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

    _loginUsers[phone] = user;

    return SendOtpResult(
      otpCode: response.otpCode,
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
    final VerifyOtpResponse response;
    try {
      response = await _networkApi.verifyOtp(
        VerifyOtpRequest(
          otpType: _loginOtpType,
          identifier: phone,
          otpCode: otpCode,
        ),
      );
    } on NetworkException catch (error) {
      throw OtpAuthException(error.message, status: error.status);
    }

    final user =
        response.user?.toLoginUser(fallbackPhone: phone) ?? _loginUsers[phone];
    if (response.verified && user != null) {
      _loginUsers[phone] = user;
    }

    final currentUser = response.verified ? await _currentUserOrNull() : null;

    return VerifyOtpResult(
      isValid: response.verified,
      message: response.status,
      user: response.verified ? currentUser ?? user : null,
    );
  }

  Future<LoginUser?> _currentUserOrNull() async {
    try {
      return (await _networkApi.getCurrentUser()).toLoginUser();
    } on NetworkException catch (error) {
      if (_isUnauthorized(error.status)) {
        await _networkApi.clearAuthToken();
      }

      return null;
    }
  }

  static bool _isUnauthorized(int? status) => status == 401 || status == 403;
}
