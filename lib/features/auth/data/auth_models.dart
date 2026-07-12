enum AuthOtpKind {
  login(apiType: 'LOGIN_2FA', previewPurpose: 'login'),
  signup(apiType: 'REGISTER', previewPurpose: 'register');

  const AuthOtpKind({required this.apiType, required this.previewPurpose});

  final String apiType;
  final String previewPurpose;
}

class SendOtpResult {
  const SendOtpResult({
    required this.expiresIn,
    this.otpCode,
    this.purpose,
    this.expiresAt,
  });

  final String? otpCode;
  final String? purpose;
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

class AuthPhoneLookupResult {
  const AuthPhoneLookupResult({
    required this.phone,
    required this.exists,
    this.user,
    this.message,
    this.status,
    this.requiredOtp = true,
    this.isTrusted,
  });

  final String phone;
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
