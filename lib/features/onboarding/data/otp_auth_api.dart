import '../../../core/config/api_config.dart';
import '../../../core/localization/app_keys.dart';
import '../../../core/localization/app_strings.dart';
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
  final int? userId;
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

  final int id;
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
    this.expiresAt,
    this.expiresIn,
    this.message,
    this.status,
  });

  final String phone;
  final bool exists;
  final LoginUser? user;
  final String? otpCode;
  final String? purpose;
  final String? expiresAt;
  final int? expiresIn;
  final String? message;
  final int? status;
}

extension on AuthUser {
  LoginUser toLoginUser({String? fallbackPhone}) {
    return LoginUser(
      id: userId ?? id ?? 0,
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

  Future<LoginUser?> restoreSession();

  Future<LoginUser> loginWithPhone(String phone);

  Future<LoginUser> signupWithPhone({
    required String phone,
    required String name,
    required String role,
    String? email,
    String? avatarPath,
  });

  Future<LoginUser> updateUser({
    required int userId,
    required String name,
    String? phone,
    String? email,
    String? avatarPath,
  });

  Future<SendOtpResult> sendLoginOtp(String phone);

  Future<SendOtpResult> sendRegisterOtp(String phone);

  Future<VerifyOtpResult> verifyLoginOtp({
    required String phone,
    required String otpCode,
    String otpType = loginOtpType,
  });

  Future<void> logout();
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
  Future<LoginUser?> restoreSession() async {
    if (!await _networkApi.hasAuthToken()) {
      return null;
    }

    try {
      final response = await _networkApi.loginResume();
      final user = response.user?.toLoginUser();
      if (user == null) {
        await _networkApi.clearAuthToken();
        return null;
      }
      if (user.id <= 0) {
        await _networkApi.clearAuthToken();
        return null;
      }
      return user;
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
      if (_isUserNotFoundStatus(error.status)) {
        _loginUsers.remove(phone);
        return AuthPhoneLookupResult(
          phone: phone,
          exists: false,
          message: error.message,
          status: error.status,
        );
      }

      throw OtpAuthException(error.message, status: error.status);
    }

    final user = response.user?.toLoginUser(fallbackPhone: phone);
    if (user == null) {
      throw OtpAuthException(AppStrings.current(AppKeys.missingOtpUser));
    }

    _loginUsers[phone] = user;
    return AuthPhoneLookupResult(
      phone: phone,
      exists: true,
      user: user,
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
      throw OtpAuthException(AppStrings.current(AppKeys.missingOtpUser));
    }

    _loginUsers[phone] = user;

    return SendOtpResult(
      otpCode: response.otpCode,
      purpose: 'login',
      expiresAt: response.expiresAt,
      expiresIn: _expiresInFrom(response.expiresAt) ?? 0,
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
      expiresIn: _expiresInFrom(response.expiresAt) ?? 0,
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
  Future<LoginUser> signupWithPhone({
    required String phone,
    required String name,
    required String role,
    String? email,
    String? avatarPath,
  }) async {
    final AuthResponse response;
    try {
      response = await _networkApi.signup(
        SignupRequest(
          phone: phone,
          name: name,
          email: email,
          role: role,
        ),
        avatarPath: avatarPath,
      );
    } on NetworkException catch (error) {
      throw OtpAuthException(error.message, status: error.status);
    }

    final user = _signupUserFromResponse(
      response,
      fallbackPhone: phone,
      fallbackName: name,
      fallbackEmail: email,
    );
    _loginUsers[phone] = user;
    return user;
  }

  @override
  Future<LoginUser> updateUser({
    required int userId,
    required String name,
    String? phone,
    String? email,
    String? avatarPath,
  }) async {
    final AuthResponse response;
    try {
      response = await _networkApi.updateUser(
        UpdateUserRequest(
          userId: userId,
          name: name,
          phone: phone,
          email: email,
        ),
        avatarPath: avatarPath,
      );
    } on NetworkException catch (error) {
      throw OtpAuthException(error.message, status: error.status);
    }

    final user = response.user?.toLoginUser(fallbackPhone: phone) ??
        LoginUser(
          id: userId,
          name: name,
          phone: phone,
          email: email,
        );
    final userPhone = user.phone?.trim();
    if (userPhone != null && userPhone.isNotEmpty) {
      _loginUsers[userPhone] = user;
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

  static LoginUser _signupUserFromResponse(
    AuthResponse response, {
    required String fallbackPhone,
    required String fallbackName,
    String? fallbackEmail,
  }) {
    final user = response.user;
    final profile = response.profile;

    return LoginUser(
      id: user?.userId ?? user?.id ?? profile?.userId ?? 0,
      email: user?.email ?? fallbackEmail,
      name: profile?.name ?? user?.name ?? fallbackName,
      phone: user?.phone ?? fallbackPhone,
      avatarUrl: profile?.avatarUrl ?? user?.avatarUrl,
      role: user?.role,
      createDt: user?.createDt ?? profile?.createDt,
      modifyDt: user?.modifyDt ?? profile?.modifyDt,
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

  @override
  Future<void> logout() async {
    _loginUsers.clear();
    await _networkApi.clearAuthToken();
  }

  static bool _isUnauthorized(int? status) => status == 401 || status == 403;

  static bool _isUserNotFoundStatus(int? status) =>
      status == 202 || status == 4006;
}
