import 'package:json_annotation/json_annotation.dart';

part 'chapter_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ChapterListRequest {
  const ChapterListRequest({
    required this.programId,
    required this.gradeId,
    required this.semesterId,
  });

  final String programId;
  final String gradeId;
  final String semesterId;

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
    this.label,
    this.description,
    this.lessonCount,
    this.displayOrder,
    this.imageUrl,
    this.createDt,
    this.modifyDt,
  });

  final String? id;
  final String? chapterId;
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
