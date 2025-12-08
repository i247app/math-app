import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request.g.dart';

@JsonSerializable()
class UpdateProfileRequest {
  @JsonKey(name: 'uid')
  final String uid;

  @JsonKey(name: 'grade')
  final String grade;

  @JsonKey(name: 'level')
  final String level;

  UpdateProfileRequest({
    required this.uid,
    required this.grade,
    required this.level,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
