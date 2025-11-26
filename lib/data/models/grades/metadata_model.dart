import 'package:json_annotation/json_annotation.dart';

part 'metadata_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MetadataModel {
  @JsonKey(name: 'has_next')
  final bool hasNext;

  @JsonKey(name: 'has_previous')
  final bool hasPrevious;

  @JsonKey(name: 'page')
  final int page;

  @JsonKey(name: 'size')
  final int size;

  @JsonKey(name: 'skip')
  final int skip;

  @JsonKey(name: 'take_all')
  final bool takeAll;

  @JsonKey(name: 'total_count')
  final int totalCount;

  @JsonKey(name: 'total_pages')
  final int totalPages;

  const MetadataModel({
    required this.hasNext,
    required this.hasPrevious,
    required this.page,
    required this.size,
    required this.skip,
    required this.takeAll,
    required this.totalCount,
    required this.totalPages,
  });

  factory MetadataModel.fromJson(Map<String, dynamic> json) =>
      _$MetadataModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataModelToJson(this);
}
