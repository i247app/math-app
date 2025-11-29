import 'package:json_annotation/json_annotation.dart';

import '../../models/profile/profile_model.dart';
import '../base/base_response.dart';

part 'profile_create_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ProfileCreateResponse extends BaseResponse {
  @JsonKey(name: 'result')
  final ProfileCreateResult? result;

  ProfileCreateResponse({this.result});

  factory ProfileCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileCreateResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProfileCreateResponseToJson(this);

  // Helper getter for easier access
  ProfileModel? get profile => result?.profile;
}

@JsonSerializable(explicitToJson: true)
class ProfileCreateResult {
  @JsonKey(name: 'profile')
  final ProfileModel? profile;

  ProfileCreateResult({this.profile});

  factory ProfileCreateResult.fromJson(Map<String, dynamic> json) =>
      _$ProfileCreateResultFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileCreateResultToJson(this);
}
