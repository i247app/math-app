import 'package:json_annotation/json_annotation.dart';
import 'package:math_ai_app/data/models/profile/profile_model.dart';
import 'package:math_ai_app/data/responses/base/base_response.dart';

part 'update_profile_response.g.dart';

@JsonSerializable(explicitToJson: true)
class UpdateProfileResponse extends BaseResponse {
  @JsonKey(name: 'result')
  final UpdateProfileResult result;

  UpdateProfileResponse({required this.result});

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UpdateProfileResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UpdateProfileResult {
  @JsonKey(name: 'profile')
  final ProfileModel profile;

  UpdateProfileResult({required this.profile});

  factory UpdateProfileResult.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileResultFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileResultToJson(this);
}
