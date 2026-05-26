import 'package:json_annotation/json_annotation.dart';

part 'semester_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SemesterListRequest {
  const SemesterListRequest({required this.userId});

  final String userId;

  factory SemesterListRequest.fromJson(Map<String, dynamic> json) =>
      _$SemesterListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SemesterListResponse {
  const SemesterListResponse({
    required this.mstatus,
    this.semesters = const <SemesterModel>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _semesterListFromJson)
  final List<SemesterModel> semesters;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory SemesterListResponse.fromJson(Map<String, dynamic> json) =>
      _$SemesterListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SemesterModel {
  const SemesterModel({
    this.id,
    this.semesterId,
    this.name,
    this.description,
    this.displayOrder,
    this.imageUrl,
    this.createDt,
    this.modifyDt,
  });

  @JsonKey(fromJson: _stringFromJson)
  final String? id;
  final String? semesterId;
  final String? name;
  final String? description;
  @JsonKey(fromJson: _intFromJson)
  final int? displayOrder;
  final String? imageUrl;
  final String? createDt;
  final String? modifyDt;

  factory SemesterModel.fromJson(Map<String, dynamic> json) =>
      _$SemesterModelFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterModelToJson(this);
}

List<SemesterModel> _semesterListFromJson(Object? value) {
  return _listFromJson(value, SemesterModel.fromJson);
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

String? _stringFromJson(Object? value) => value?.toString();
