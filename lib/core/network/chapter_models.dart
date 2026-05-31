import 'package:json_annotation/json_annotation.dart';

part 'chapter_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ChapterListRequest {
  const ChapterListRequest({
    required this.programId,
    required this.gradeId,
    required this.semesterId,
  });

  final int programId;
  final int gradeId;
  final int semesterId;

  factory ChapterListRequest.fromJson(Map<String, dynamic> json) =>
      _$ChapterListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ChapterListResponse {
  const ChapterListResponse({
    required this.mstatus,
    this.chapters = const <ChapterModel>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final List<ChapterModel> chapters;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ChapterListResponse.fromJson(Map<String, dynamic> json) {
    return _$ChapterListResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ChapterListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ChapterModel {
  const ChapterModel({
    this.id,
    this.chapterId,
    this.programId,
    this.gradeId,
    this.semesterId,
    this.label,
    this.description,
    this.lessonCount,
    this.displayOrder,
    this.imageUrl,
    this.createDt,
    this.modifyDt,
  });

  final int? id;
  @JsonKey(fromJson: _intFromJson)
  final int? chapterId;
  @JsonKey(fromJson: _intFromJson)
  final int? programId;
  @JsonKey(fromJson: _intFromJson)
  final int? gradeId;
  @JsonKey(fromJson: _intFromJson)
  final int? semesterId;
  final String? label;
  final String? description;
  final int? lessonCount;
  final int? displayOrder;
  final String? imageUrl;
  final String? createDt;
  final String? modifyDt;

  factory ChapterModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterModelToJson(this);
}

int? _intFromJson(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}
