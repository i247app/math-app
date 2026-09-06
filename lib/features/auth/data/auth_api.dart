import 'package:dio/dio.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/errors/http_status.dart';
import 'package:numi/features/auth/data/auth_service.dart';
import 'package:numi/features/auth/data/auth_api_models.dart';
import 'package:numi/features/auth/data/device_api_models.dart';
import 'package:numi/features/auth/data/auth_conversion.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/auth/data/auth_exception.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/auth/helpers/auth_status.dart';

class AuthApi implements AuthService {
  AuthApi({String? baseUrl, NetworkClient? networkClient})
    : _networkClient =
          networkClient ??
          (baseUrl == null
              ? NetworkClient.shared
              : NetworkClient(baseUrl: baseUrl));

  final NetworkClient _networkClient;
  final Map<String, LoginUser> _loginUsers = {};

  @override
  Future<LoginUser?> restoreSession() async {
    if (!await _networkClient.hasAuthToken()) {
      return null;
    }

    try {
      final response = await _postAuth(
        '/auth/login-resume',
        const <String, dynamic>{},
      );
      final user = response.user?.toModel();
      if (user == null || user.id <= 0) {
        await _networkClient.clearAuthToken();
        return null;
      }
      return user;
    } on NetworkException catch (error) {
      await _clearAuthTokenIfUnauthorized(error);
      return null;
    }
  }

  @override
  Future<AuthLoginLookupResult> lookupLoginName(String loginName) async {
    final AuthResponse response;
    try {
      response = await _postAuth(
        '/auth/login',
        LoginRequest(loginName: loginName).toJson(),
      );
    } on NetworkException catch (error) {
      if (isAuthUserNotFoundStatus(error.status)) {
        _loginUsers.remove(loginName);
        return AuthLoginLookupResult(
          loginName: loginName,
          exists: false,
          message: error.message,
          status: error.status,
        );
      }

      throw AuthException(error.message, status: error.status);
    }

    final user = response.user?.toModel(fallbackLoginName: loginName);
    if (user == null) {
      throw AuthException(AppStrings.current(AppKeys.missingOtpUser));
    }

    _loginUsers[loginName] = user;
    return AuthLoginLookupResult(
      loginName: loginName,
      exists: true,
      user: user,
      requiredOtp: response.requiredOtp ?? true,
      isTrusted: response.isTrusted,
    );
  }

  @override
  Future<SendOtpResult> sendOtp({
    required String loginName,
    required AuthOtpKind kind,
    int? userId,
    int? targetDeviceId,
  }) async {
    final response = await _request(
      () => _sendOtp(
        SendOtpRequest(
          otpType: kind.apiType,
          identifier: loginName,
          userId: userId,
          targetDeviceId: targetDeviceId,
        ),
      ),
    );

    return response.toModel(kind: kind);
  }

  @override
  Future<List<AuthTrustedDevice>> listTrustedDevices({
    required int userId,
  }) async {
    final response = await _request(
      () => _listDevices(DeviceListRequest(userId: userId, isVerified: true)),
    );

    return response.devices
        .map((device) => device.toModel())
        .whereType<AuthTrustedDevice>()
        .toList(growable: false);
  }

  @override
  Future<LoginUser> signupWithPhone({
    required String phone,
    required String name,
    required String role,
    String? email,
  }) async {
    final response = await _request(
      () => _signup(
        SignupRequest(phone: phone, name: name, email: email, role: role),
      ),
    );

    final user = response.toSignupModel(
      fallbackPhone: phone,
      fallbackName: name,
      fallbackEmail: email,
    );
    _loginUsers[phone] = user;
    final userEmail = user.email?.trim();
    if (userEmail != null && userEmail.isNotEmpty) {
      _loginUsers[userEmail] = user;
    }
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
      () => _updateUser(
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
        response.user?.toModel(fallbackLoginName: phone) ??
        LoginUser(id: userId, name: name, phone: phone, email: email);
    final userPhone = user.phone?.trim();
    if (userPhone != null && userPhone.isNotEmpty) {
      _loginUsers[userPhone] = user;
    }
    return user;
  }

  @override
  Future<VerifyOtpResult> verifyOtp({
    required String loginName,
    required String otpCode,
    required AuthOtpKind kind,
  }) async {
    final response = await _request(
      () => _verifyOtp(
        VerifyOtpRequest(
          otpType: kind.apiType,
          identifier: loginName,
          otpCode: otpCode,
        ),
      ),
    );

    final user =
        response.user?.toModel(fallbackLoginName: loginName) ??
        _loginUsers[loginName];
    if (response.verified && user != null) {
      _loginUsers[loginName] = user;
    }

    final currentUser = response.verified ? await _currentUserOrNull() : null;

    return VerifyOtpResult(
      isValid: response.verified,
      message: response.status,
      user: response.verified ? currentUser ?? user : null,
    );
  }

  @override
  Future<void> clearPendingLogin(String loginName) async {
    _loginUsers.remove(loginName);
  }

  Future<LoginUser?> _currentUserOrNull() async {
    try {
      return (await _getCurrentUser()).toModel();
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
      await _networkClient.clearAuthToken();
    }
  }

  @override
  Future<void> logout() async {
    _loginUsers.clear();
    await _networkClient.clearAuthToken();
  }

  Future<AuthResponse> _signup(
    SignupRequest request, {
    String? avatarPath,
  }) async {
    final formData = FormData.fromMap({
      'phone': request.phone,
      if (request.email?.isNotEmpty == true) 'email': request.email,
      if (request.name?.isNotEmpty == true) 'name': request.name,
      if (request.role?.isNotEmpty == true) 'role': request.role,
      if (avatarPath?.isNotEmpty == true)
        'avatar': await MultipartFile.fromFile(avatarPath!),
    });
    final json = await _networkClient.postMultipart('/users/create', formData);
    NetworkClient.throwForApiStatus(json);
    final response = AuthResponse.fromJson(json);
    await _storeAccessToken(response.accessToken);
    return response;
  }

  Future<AuthResponse> _updateUser(
    UpdateUserRequest request, {
    String? avatarPath,
  }) async {
    final formData = FormData.fromMap({
      'user_id': request.userId,
      if (request.name?.isNotEmpty == true) 'name': request.name,
      if (request.phone?.isNotEmpty == true) 'phone': request.phone,
      if (request.email?.isNotEmpty == true) 'email': request.email,
      if (avatarPath?.isNotEmpty == true)
        'avatar': await MultipartFile.fromFile(avatarPath!),
    });
    final json = await _networkClient.postMultipart('/users/update', formData);
    NetworkClient.throwForApiStatus(json);
    return AuthResponse.fromJson(json);
  }

  Future<AuthResponse> _postAuth(String path, Map<String, dynamic> body) async {
    final json = await _networkClient.postJson(path, body);
    NetworkClient.throwForApiStatus(json);
    final response = AuthResponse.fromJson(json);
    await _storeAccessToken(response.accessToken);
    return response;
  }

  Future<SendOtpResponse> _sendOtp(SendOtpRequest request) async {
    final json = await _networkClient.postJson('/otps/send', request.toJson());
    NetworkClient.throwForApiStatus(json);
    return SendOtpResponse.fromJson(json);
  }

  Future<VerifyOtpResponse> _verifyOtp(VerifyOtpRequest request) async {
    final json = await _networkClient.postJson(
      '/otps/verify',
      request.toJson(),
    );
    NetworkClient.throwForApiStatus(json);
    final response = VerifyOtpResponse.fromJson(json);
    await _storeAccessToken(response.accessToken);
    return response;
  }

  Future<DeviceListResponse> _listDevices(DeviceListRequest request) async {
    final json = await _networkClient.postJson(
      '/devices/list',
      request.toJson(),
    );
    NetworkClient.throwForApiStatus(json);
    return DeviceListResponse.fromJson(json);
  }

  Future<AuthUser> _getCurrentUser() async {
    final json = await _networkClient.postJson(
      '/users/me',
      const <String, dynamic>{},
    );
    NetworkClient.throwForApiStatus(json);
    if (json.containsKey('user') && json['user'] == null) {
      throw const NetworkException('Session expired.', status: 401);
    }
    final data = json['data'];
    final user = json['user'] ?? _nestedUser(data) ?? data;
    if (user case final Map<String, dynamic> userJson) {
      return AuthUser.fromJson(userJson);
    }
    if (user case final Map<Object?, Object?> userJson) {
      return AuthUser.fromJson(Map<String, dynamic>.from(userJson));
    }
    return AuthUser.fromJson(json);
  }

  Future<void> _storeAccessToken(String? accessToken) async {
    final token = accessToken?.trim();
    if (token != null && token.isNotEmpty) {
      await _networkClient.writeAuthToken(token);
    }
  }

  static Object? _nestedUser(Object? data) {
    if (data case final Map<String, dynamic> dataJson) {
      return dataJson['user'];
    }
    if (data case final Map<Object?, Object?> dataJson) {
      return dataJson['user'];
    }
    return null;
  }
}
