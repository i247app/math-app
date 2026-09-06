import 'package:numi/features/auth/models/auth_models.dart';

abstract interface class AuthService {
  Future<AuthLoginLookupResult> lookupLoginName(String loginName);

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
    required String loginName,
    required AuthOtpKind kind,
    int? userId,
    int? targetDeviceId,
  });

  Future<List<AuthTrustedDevice>> listTrustedDevices({required int userId});

  Future<VerifyOtpResult> verifyOtp({
    required String loginName,
    required String otpCode,
    required AuthOtpKind kind,
  });

  Future<void> clearPendingLogin(String loginName);

  Future<void> logout();
}
