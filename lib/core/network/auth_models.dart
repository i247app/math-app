import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable(includeIfNull: false)
class SignupRequest {
  const SignupRequest({
    required this.phone,
    this.email,
    this.name,
  });

  final String phone;
  final String? email;
  final String? name;

  factory SignupRequest.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SignupRequestToJson(this);
}

@JsonSerializable()
class LoginRequest {
  const LoginRequest({required this.phone});

  final String phone;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SendOtpRequest {
  const SendOtpRequest({
    required this.otpType,
    required this.identifier,
  });

  final String otpType;
  final String identifier;

  factory SendOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$SendOtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendOtpRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerifyOtpRequest {
  const VerifyOtpRequest({
    required this.otpType,
    required this.identifier,
    required this.otpCode,
  });

  final String otpType;
  final String identifier;
  final String otpCode;

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AuthResponse {
  const AuthResponse({
    required this.mstatus,
    this.status,
    this.mmessage,
    this.debug,
    this.expiresAt,
    this.otpCode,
    this.user,
    this.profile,
  });

  final int mstatus;
  final String? status;
  final String? mmessage;
  final String? debug;
  @JsonKey(name: 'expires_at')
  final String? expiresAt;
  @JsonKey(name: 'otp_code')
  final String? otpCode;
  final AuthUser? user;
  final AuthProfile? profile;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SendOtpResponse {
  const SendOtpResponse({
    required this.mstatus,
    this.expiresAt,
    this.otpCode,
    this.otpType,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final String? expiresAt;
  final String? otpCode;
  final String? otpType;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) =>
      _$SendOtpResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SendOtpResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class VerifyOtpResponse {
  const VerifyOtpResponse({
    required this.mstatus,
    this.otpType,
    this.status,
    this.mmessage,
    this.debug,
    this.user,
    this.verified = false,
  });

  final int mstatus;
  final String? otpType;
  final String? status;
  final String? mmessage;
  final String? debug;
  final AuthUser? user;
  @JsonKey(defaultValue: false)
  final bool verified;

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AuthProfile {
  const AuthProfile({
    this.id,
    this.profileId,
    this.userId,
    this.name,
    this.avatarKey,
    this.avatarUrl,
    this.createDt,
    this.modifyDt,
  });

  @JsonKey(fromJson: AuthUser._stringFromJson)
  final String? id;
  final String? profileId;
  final String? userId;
  final String? name;
  final String? avatarKey;
  final String? avatarUrl;
  final String? createDt;
  final String? modifyDt;

  factory AuthProfile.fromJson(Map<String, dynamic> json) =>
      _$AuthProfileFromJson(json);

  Map<String, dynamic> toJson() => _$AuthProfileToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AuthUser {
  const AuthUser({
    this.id,
    this.userId,
    this.email,
    this.name,
    this.phone,
    this.avatarKey,
    this.avatarUrl,
    this.role,
    this.createDt,
    this.modifyDt,
  });

  @JsonKey(fromJson: _stringFromJson)
  final String? id;
  final String? userId;
  final String? email;
  final String? name;
  final String? phone;
  final String? avatarKey;
  final String? avatarUrl;
  final String? role;
  final String? createDt;
  final String? modifyDt;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  Map<String, dynamic> toJson() => _$AuthUserToJson(this);

  static String? _stringFromJson(Object? value) => value?.toString();
}
