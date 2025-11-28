import 'package:json_annotation/json_annotation.dart';

part 'level_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LevelModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'label')
  final String label;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'icon_url')
  final String iconUrl;

  @JsonKey(name: 'display_order')
  final int displayOrder;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'modified_at')
  final String modifiedAt;

  const LevelModel({
    required this.id,
    required this.label,
    required this.description,
    required this.iconUrl,
    required this.displayOrder,
    required this.status,
    required this.createdAt,
    required this.modifiedAt,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) =>
      _$LevelModelFromJson(json);

  Map<String, dynamic> toJson() => _$LevelModelToJson(this);
}
