import 'package:json_annotation/json_annotation.dart';
import 'package:math_ai_app/data/responses/base/base_response.dart';

import '../../models/user/user_model.dart';

part 'login_response.g.dart';

@JsonSerializable(explicitToJson: true)
class LoginResponse extends BaseResponse {
  @JsonKey(name: 'is_secure')
  bool? isSecure;

  @JsonKey(name: 'login_status')
  String? loginStatus;

  @JsonKey(name: 'needs_2fa')
  bool? needs2fa;

  @JsonKey(name: 'user')
  User? user;

  LoginResponse({this.isSecure, this.loginStatus, this.needs2fa, this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
  @override
  bool get isSuccess => status == 200 && user != null;
}
