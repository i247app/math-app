import 'package:json_annotation/json_annotation.dart';

import '../../models/user/user_model.dart';
import '../base/base_response.dart';

part 'sign_up_response.g.dart';

@JsonSerializable(explicitToJson: true)
class SignUpResponse extends BaseResponse {
  @JsonKey(name: 'result')
  SignUpResult? result;

  SignUpResponse({
    super.status,
    super.error,
    super.message,
    super.blockUtilDt,
    this.result,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) =>
      _$SignUpResponseFromJson(json);

  factory SignUpResponse.fromJsonWithCode(Map<String, dynamic> json, int code) {
    final instance = _$SignUpResponseFromJson(json);
    instance.httpStatusCode = code;
    return instance;
  }

  @override
  Map<String, dynamic> toJson() => _$SignUpResponseToJson(this);

  // Helper getter for easier access
  User? get user => result?.user;
}

@JsonSerializable(explicitToJson: true)
class SignUpResult {
  @JsonKey(name: 'user')
  User? user;

  SignUpResult({this.user});

  factory SignUpResult.fromJson(Map<String, dynamic> json) =>
      _$SignUpResultFromJson(json);

  Map<String, dynamic> toJson() => _$SignUpResultToJson(this);
}
