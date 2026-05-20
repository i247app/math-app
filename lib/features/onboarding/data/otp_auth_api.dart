import '../../../core/config/api_config.dart';
import '../../../core/network/auth_models.dart';
import '../../../core/network/network_client.dart';

const loginOtpType = 'LOGIN_2FA';
const registerOtpType = 'REGISTER';

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
    this.createDt,
    this.modifyDt,
  });

  final String id;
  final String? email;
  final String? name;
  final String? phone;
  final String? avatarUrl;
  final String? role;
  final String? createDt;
  final String? modifyDt;
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
      createDt: createDt,
      modifyDt: modifyDt,
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

  Future<SendOtpResult> sendRegisterOtp(String phone);

  Future<VerifyOtpResult> verifyLoginOtp({
    required String phone,
    required String otpCode,
    String otpType = loginOtpType,
  });
}

class OtpAuthApi implements OtpAuthService {
  OtpAuthApi({
    String? baseUrl,
    NetworkApi? networkApi,
  }) : _networkApi =
            networkApi ?? NetworkApi(baseUrl: baseUrl ?? ApiConfig.baseUrl);

  final NetworkApi _networkApi;
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
  Future<SendOtpResult> sendRegisterOtp(String phone) async {
    final SendOtpResponse response;
    try {
      response = await _networkApi.sendOtp(
        SendOtpRequest(
          otpType: registerOtpType,
          identifier: phone,
        ),
      );
    } on NetworkException catch (error) {
      throw OtpAuthException(error.message, status: error.status);
    }

    return SendOtpResult(
      otpCode: response.otpCode,
      purpose: 'register',
      expiresAt: response.expiresAt,
      expiresIn: _expiresInFrom(response.expiresAt) ?? 180,
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
    String otpType = loginOtpType,
  }) async {
    final VerifyOtpResponse response;
    try {
      response = await _networkApi.verifyOtp(
        VerifyOtpRequest(
          otpType: otpType,
          identifier: phone,
          otpCode: otpCode,
        ),
      );
    } on NetworkException catch (error) {
      throw OtpAuthException(error.message, status: error.status);
    }

    final user = response.user?.toLoginUser(fallbackPhone: phone) ??
        _loginUsers[phone];
    if (response.verified && user != null) {
      _loginUsers[phone] = user;
    }

    return VerifyOtpResult(
      isValid: response.verified,
      message: response.status,
      user: response.verified ? user : null,
    );
  }

  static int? _expiresInFrom(String? expiresAt) {
    if (expiresAt == null) {
      return null;
    }

    final parsed = DateTime.tryParse(expiresAt);
    if (parsed == null) {
      return null;
    }

    final seconds = parsed.toUtc().difference(DateTime.now().toUtc()).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }
}
