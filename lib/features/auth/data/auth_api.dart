import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/errors/http_status.dart';
import 'package:numi/core/network/auth_models.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/auth/data/auth_exception.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/auth/errors/auth_status.dart';

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

abstract class AuthService {
  Future<AuthPhoneLookupResult> lookupLoginPhone(String phone);

  Future<LoginUser?> restoreSession();

  Future<LoginUser> signupWithPhone({
    required String phone,
    required String name,
    required String role,
    String? email,
  });

  Future<LoginUser> updateUser({
    required int userId,
    required String name,
    String? phone,
    String? email,
    String? avatarPath,
  });

  Future<SendOtpResult> sendOtp({
    required String phone,
    required AuthOtpKind kind,
  });

  Future<VerifyOtpResult> verifyOtp({
    required String phone,
    required String otpCode,
    required AuthOtpKind kind,
  });

  Future<void> clearPendingLogin(String phone);

  Future<void> logout();
}

class AuthApi implements AuthService {
  AuthApi({String? baseUrl, NetworkApi? networkApi})
    : _networkApi =
          networkApi ??
          (baseUrl == null ? NetworkApi.shared : NetworkApi(baseUrl: baseUrl));

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
      if (user == null || user.id <= 0) {
        await _networkApi.clearAuthToken();
        return null;
      }
      return user;
    } on NetworkException catch (error) {
      await _clearAuthTokenIfUnauthorized(error);
      return null;
    }
  }

  @override
  Future<AuthPhoneLookupResult> lookupLoginPhone(String phone) async {
    final AuthResponse response;
    try {
      response = await _networkApi.login(LoginRequest(phone: phone));
    } on NetworkException catch (error) {
      if (isAuthUserNotFoundStatus(error.status)) {
        _loginUsers.remove(phone);
        return AuthPhoneLookupResult(
          phone: phone,
          exists: false,
          message: error.message,
          status: error.status,
        );
      }

      throw AuthException(error.message, status: error.status);
    }

    final user = response.user?.toLoginUser(fallbackPhone: phone);
    if (user == null) {
      throw AuthException(AppStrings.current(AppKeys.missingOtpUser));
    }

    _loginUsers[phone] = user;
    return AuthPhoneLookupResult(
      phone: phone,
      exists: true,
      user: user,
      requiredOtp: response.requiredOtp ?? true,
      isTrusted: response.isTrusted,
    );
  }

  @override
  Future<SendOtpResult> sendOtp({
    required String phone,
    required AuthOtpKind kind,
  }) async {
    final response = await _request(
      () => _networkApi.sendOtp(
        SendOtpRequest(otpType: kind.apiType, identifier: phone),
      ),
    );

    return SendOtpResult(
      otpCode: response.otpCode,
      purpose: kind.previewPurpose,
      expiresAt: response.expiresAt,
      expiresIn: _expiresInFrom(response.expiresAt) ?? 0,
    );
  }

  @override
  Future<LoginUser> signupWithPhone({
    required String phone,
    required String name,
    required String role,
    String? email,
  }) async {
    final response = await _request(
      () => _networkApi.signup(
        SignupRequest(phone: phone, name: name, email: email, role: role),
      ),
    );

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
    final response = await _request(
      () => _networkApi.updateUser(
        UpdateUserRequest(
          userId: userId,
          name: name,
          phone: phone,
          email: email,
        ),
        avatarPath: avatarPath,
      ),
    );

    final user =
        response.user?.toLoginUser(fallbackPhone: phone) ??
        LoginUser(id: userId, name: name, phone: phone, email: email);
    final userPhone = user.phone?.trim();
    if (userPhone != null && userPhone.isNotEmpty) {
      _loginUsers[userPhone] = user;
    }
    return user;
  }

  @override
  Future<VerifyOtpResult> verifyOtp({
    required String phone,
    required String otpCode,
    required AuthOtpKind kind,
  }) async {
    final response = await _request(
      () => _networkApi.verifyOtp(
        VerifyOtpRequest(
          otpType: kind.apiType,
          identifier: phone,
          otpCode: otpCode,
        ),
      ),
    );

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

  @override
  Future<void> clearPendingLogin(String phone) async {
    _loginUsers.remove(phone);
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
      await _clearAuthTokenIfUnauthorized(error);

      return null;
    }
  }

  Future<T> _request<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on NetworkException catch (error) {
      throw AuthException(error.message, status: error.status);
    }
  }

  Future<void> _clearAuthTokenIfUnauthorized(NetworkException error) async {
    if (isUnauthorizedHttpStatus(error.status)) {
      await _networkApi.clearAuthToken();
    }
  }

  @override
  Future<void> logout() async {
    _loginUsers.clear();
    await _networkApi.clearAuthToken();
  }
}
