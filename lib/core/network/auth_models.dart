import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable(includeIfNull: false)
class SignupRequest {
  const SignupRequest({
    required this.phone,
    this.email,
  });

  final String phone;
  final String? email;

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

@JsonSerializable(explicitToJson: true)
class AuthResponse {
  const AuthResponse({
    required this.mstatus,
    this.status,
    this.mmessage,
    this.debug,
    this.user,
  });

  final int mstatus;
  final String? status;
  final String? mmessage;
  final String? debug;
  final AuthUser? user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AuthUser {
  const AuthUser({
    this.id,
    this.email,
    this.name,
    this.phone,
    this.avatarUrl,
    this.role,
  });

  final String? id;
  final String? email;
  final String? name;
  final String? phone;
  final String? avatarUrl;
  final String? role;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  Map<String, dynamic> toJson() => _$AuthUserToJson(this);
}
