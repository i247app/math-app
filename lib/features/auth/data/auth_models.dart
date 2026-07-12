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
    this.requiredOtp = true,
    this.user,
    this.otpId,
    this.otpCode,
    this.purpose,
    this.expiresAt,
    this.message,
  });

  final bool requiredOtp;
  final LoginUser? user;
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
    this.requiredOtp = true,
    this.isTrusted,
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
  final bool requiredOtp;
  final bool? isTrusted;
}

class VerifyOtpResult {
  const VerifyOtpResult({required this.isValid, this.message, this.user});

  final bool isValid;
  final String? message;
  final LoginUser? user;
}
