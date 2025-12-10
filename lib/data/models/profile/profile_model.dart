import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProfileModel {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'uid')
  final String? uid;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'grade')
  final String? grade;

  @JsonKey(name: 'semester')
  final String? semester;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'modified_at')
  final String? modifiedAt;

  ProfileModel({
    this.id,
    this.uid,
    this.name,
    this.email,
    this.phone,
    this.grade,
    this.semester,
    this.avatarUrl,
    this.status,
    this.createdAt,
    this.modifiedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
