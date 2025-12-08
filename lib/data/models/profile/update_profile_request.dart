import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request.g.dart';

@JsonSerializable()
class UpdateProfileRequest {
  @JsonKey(name: 'uid')
  final String uid;

  @JsonKey(name: 'grade_id')
  final String gradeId;

  @JsonKey(name: 'semester_id')
  final String semesterId;

  UpdateProfileRequest({
    required this.uid,
    required this.gradeId,
    required this.semesterId,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
