import 'package:json_annotation/json_annotation.dart';

import '../../models/profile/profile_model.dart';
import '../base/base_response.dart';

part 'profile_fetch_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ProfileFetchResponse extends BaseResponse {
  @JsonKey(name: 'result')
  final ProfileFetchResult? result;

  ProfileFetchResponse({this.result});

  factory ProfileFetchResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileFetchResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProfileFetchResponseToJson(this);

  // Helper getter for easier access
  ProfileModel? get profile => result?.profile;
}

@JsonSerializable(explicitToJson: true)
class ProfileFetchResult {
  @JsonKey(name: 'profile')
  final ProfileModel? profile;

  ProfileFetchResult({this.profile});

  factory ProfileFetchResult.fromJson(Map<String, dynamic> json) =>
      _$ProfileFetchResultFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileFetchResultToJson(this);
}
