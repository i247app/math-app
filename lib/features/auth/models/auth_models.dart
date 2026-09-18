enum AuthOtpKind {
  login(apiType: 'LOGIN_2FA'),
  signup(apiType: 'REGISTER');

  const AuthOtpKind({required this.apiType});

  final String apiType;
}

class SendOtpResult {
  const SendOtpResult({required this.expiresIn, this.expiresAt});

  final int expiresIn;
  final String? expiresAt;
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

class AuthTrustedDevice {
  const AuthTrustedDevice({
    required this.deviceId,
    required this.deviceName,
    this.deviceUuid,
    this.platform,
  });

  final int deviceId;
  final String deviceName;
  final String? deviceUuid;
  final String? platform;
}

class AuthLoginLookupResult {
  const AuthLoginLookupResult({
    required this.loginName,
    required this.exists,
    this.user,
    this.message,
    this.status,
    this.requiredOtp = true,
    this.isTrusted,
  });

  final String loginName;
  final bool exists;
  final LoginUser? user;
  final String? message;
  final int? status;
  final bool requiredOtp;
  final bool? isTrusted;
}

class VerifyOtpResult {
  const VerifyOtpResult({required this.isValid, this.message, this.user});

  final bool isValid;
  final String? message;
  final LoginUser? user;
}
