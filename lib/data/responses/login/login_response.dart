import 'package:json_annotation/json_annotation.dart';
import 'package:math_ai_app/data/responses/base/base_response.dart';

import '../../models/user/user_model.dart';

part 'login_response.g.dart';

@JsonSerializable(explicitToJson: true)
class LoginResponse extends BaseResponse {
  @JsonKey(name: 'result')
  LoginResult? result;

  LoginResponse({this.result});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  // Helper getters for easier access
  bool? get isSecure => result?.isSecure;
  String? get loginStatus => result?.loginStatus;
  bool? get needs2fa => result?.needs2fa;
  User? get user => result?.user;
}

@JsonSerializable(explicitToJson: true)
class LoginResult {
  @JsonKey(name: 'is_secure')
  bool? isSecure;

  @JsonKey(name: 'login_status')
  String? loginStatus;

  @JsonKey(name: 'needs_2fa')
  bool? needs2fa;

  @JsonKey(name: 'user')
  User? user;

  LoginResult({this.isSecure, this.loginStatus, this.needs2fa, this.user});

  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResultToJson(this);
}
