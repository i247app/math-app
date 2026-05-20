// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupRequest _$SignupRequestFromJson(Map<String, dynamic> json) =>
    SignupRequest(
      phone: json['phone'] as String,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$SignupRequestToJson(SignupRequest instance) {
  final val = <String, dynamic>{
    'phone': instance.phone,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('email', instance.email);
  return val;
}

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'phone': instance.phone,
    };

VerifyOtpRequest _$VerifyOtpRequestFromJson(Map<String, dynamic> json) =>
    VerifyOtpRequest(
      otpType: json['otp_type'] as String,
      identifier: json['identifier'] as String,
      otpCode: json['otp_code'] as String,
    );

Map<String, dynamic> _$VerifyOtpRequestToJson(VerifyOtpRequest instance) =>
    <String, dynamic>{
      'otp_type': instance.otpType,
      'identifier': instance.identifier,
      'otp_code': instance.otpCode,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      mstatus: (json['mstatus'] as num).toInt(),
      status: json['status'] as String?,
      mmessage: json['mmessage'] as String?,
      debug: json['debug'] as String?,
      otpCode: json['otpCode'] as String?,
      user: json['user'] == null
          ? null
          : AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'mstatus': instance.mstatus,
      'status': instance.status,
      'mmessage': instance.mmessage,
      'debug': instance.debug,
      'otpCode': instance.otpCode,
      'user': instance.user?.toJson(),
    };

VerifyOtpResponse _$VerifyOtpResponseFromJson(Map<String, dynamic> json) =>
    VerifyOtpResponse(
      mstatus: (json['mstatus'] as num).toInt(),
      otpType: json['otp_type'] as String?,
      status: json['status'] as String?,
      mmessage: json['mmessage'] as String?,
      debug: json['debug'] as String?,
      user: json['user'] == null
          ? null
          : AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      verified: json['verified'] as bool? ?? false,
    );

Map<String, dynamic> _$VerifyOtpResponseToJson(VerifyOtpResponse instance) =>
    <String, dynamic>{
      'mstatus': instance.mstatus,
      'otp_type': instance.otpType,
      'status': instance.status,
      'mmessage': instance.mmessage,
      'debug': instance.debug,
      'user': instance.user?.toJson(),
      'verified': instance.verified,
    };

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => AuthUser(
      id: AuthUser._stringFromJson(json['id']),
      userId: json['user_id'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$AuthUserToJson(AuthUser instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'email': instance.email,
      'name': instance.name,
      'phone': instance.phone,
      'avatar_url': instance.avatarUrl,
      'role': instance.role,
    };
