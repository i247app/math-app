import 'package:json_annotation/json_annotation.dart';

part 'school_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class SchoolListRequest {
  const SchoolListRequest({this.page, this.size, this.skip, this.takeAll});

  final int? page;
  final int? size;
  final int? skip;
  final bool? takeAll;

  factory SchoolListRequest.fromJson(Map<String, dynamic> json) =>
      _$SchoolListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SchoolListResponse {
  const SchoolListResponse({
    required this.mstatus,
    this.pagination,
    this.schools = const <SchoolModel>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _schoolPaginationFromJson)
  final SchoolPagination? pagination;
  @JsonKey(fromJson: _schoolListFromJson)
  final List<SchoolModel> schools;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory SchoolListResponse.fromJson(Map<String, dynamic> json) =>
      _$SchoolListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SchoolPagination {
  const SchoolPagination({
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

  factory SchoolPagination.fromJson(Map<String, dynamic> json) =>
      _$SchoolPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolPaginationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SchoolModel {
  const SchoolModel({
    this.id,
    this.schoolId,
    this.name,
    this.imageUrl,
    this.createDt,
    this.modifyDt,
  });

  @JsonKey(fromJson: _intFromJson)
  final int? id;
  @JsonKey(fromJson: _intFromJson)
  final int? schoolId;
  final String? name;
  final String? imageUrl;
  final String? createDt;
  final String? modifyDt;

  factory SchoolModel.fromJson(Map<String, dynamic> json) =>
      _$SchoolModelFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolModelToJson(this);
}

SchoolPagination? _schoolPaginationFromJson(Object? value) {
  return _objectFromJson(value, SchoolPagination.fromJson);
}

List<SchoolModel> _schoolListFromJson(Object? value) {
  return _listFromJson(value, SchoolModel.fromJson);
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
