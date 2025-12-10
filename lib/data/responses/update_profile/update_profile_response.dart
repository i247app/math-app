import 'package:json_annotation/json_annotation.dart';

import '../base/base_response.dart';

part 'update_profile_response.g.dart';

@JsonSerializable(explicitToJson: true)
class UpdateProfileResponse extends BaseResponse {
  @JsonKey(name: 'result')
  UpdateProfileResult? result;

  UpdateProfileResponse({
    super.status,
    super.error,
    super.message,
    super.blockUtilDt,
    this.result,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileResponseFromJson(json);

  factory UpdateProfileResponse.fromJsonWithCode(
    Map<String, dynamic> json,
    int code,
  ) {
    final instance = _$UpdateProfileResponseFromJson(json);
    instance.httpStatusCode = code;
    return instance;
  }

  @override
  Map<String, dynamic> toJson() => _$UpdateProfileResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UpdateProfileResult {
  @JsonKey(name: 'success')
  bool? success;

  UpdateProfileResult({this.success});

  factory UpdateProfileResult.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileResultFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileResultToJson(this);
}
