import 'package:json_annotation/json_annotation.dart';

part 'grade_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class GradeListRequest {
  const GradeListRequest({required this.userId});

  final int userId;

  factory GradeListRequest.fromJson(Map<String, dynamic> json) =>
      _$GradeListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GradeListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class GradeListResponse {
  const GradeListResponse({
    required this.mstatus,
    this.grades = const <GradeModel>[],
    this.pagination,
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _gradeListFromJson)
  final List<GradeModel> grades;
  @JsonKey(fromJson: _gradePaginationFromJson)
  final GradePagination? pagination;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory GradeListResponse.fromJson(Map<String, dynamic> json) =>
      _$GradeListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GradeListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GradePagination {
  const GradePagination({
    this.hasNext,
    this.hasPrevious,
    this.page,
    this.size,
    this.skip,
    this.takeAll,
    this.totalCount,
    this.totalPages,
  });

  final bool? hasNext;
  final bool? hasPrevious;
  @JsonKey(fromJson: _intFromJson)
  final int? page;
  @JsonKey(fromJson: _intFromJson)
  final int? size;
  @JsonKey(fromJson: _intFromJson)
  final int? skip;
  final bool? takeAll;
  @JsonKey(fromJson: _intFromJson)
  final int? totalCount;
  @JsonKey(fromJson: _intFromJson)
  final int? totalPages;

  factory GradePagination.fromJson(Map<String, dynamic> json) =>
      _$GradePaginationFromJson(json);

  Map<String, dynamic> toJson() => _$GradePaginationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GradeModel {
  const GradeModel({
    this.id,
    this.gradeId,
    this.label,
    this.description,
    this.displayOrder,
    this.imageUrl,
    this.createDt,
    this.modifyDt,
  });

  @JsonKey(fromJson: _intFromJson)
  final int? id;
  @JsonKey(fromJson: _intFromJson)
  final int? gradeId;
  final String? label;
  final String? description;
  @JsonKey(fromJson: _intFromJson)
  final int? displayOrder;
  final String? imageUrl;
  final String? createDt;
  final String? modifyDt;

  factory GradeModel.fromJson(Map<String, dynamic> json) =>
      _$GradeModelFromJson(json);

  Map<String, dynamic> toJson() => _$GradeModelToJson(this);
}

GradePagination? _gradePaginationFromJson(Object? value) {
  return _objectFromJson(value, GradePagination.fromJson);
}

List<GradeModel> _gradeListFromJson(Object? value) {
  return _listFromJson(value, GradeModel.fromJson);
}

T? _objectFromJson<T>(
  Object? value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value case final Map<String, dynamic> json) {
    return fromJson(json);
  }
  if (value case final Map<Object?, Object?> json) {
    return fromJson(Map<String, dynamic>.from(json));
  }
  return null;
}

List<T> _listFromJson<T>(
  Object? value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is! List) {
    return <T>[];
  }

  return value
      .map((item) => _objectFromJson(item, fromJson))
      .whereType<T>()
      .toList();
}

int _requiredIntFromJson(Object? value) => _intFromJson(value) ?? 0;

int? _intFromJson(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}
