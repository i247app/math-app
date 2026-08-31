import 'package:json_annotation/json_annotation.dart';

part 'semester_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SemesterListRequest {
  const SemesterListRequest({required this.userId});

  final int userId;

  factory SemesterListRequest.fromJson(Map<String, dynamic> json) =>
      _$SemesterListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SemesterListResponse {
  const SemesterListResponse({
    required this.mstatus,
    this.semesters = const <SemesterDto>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _semesterListFromJson)
  final List<SemesterDto> semesters;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory SemesterListResponse.fromJson(Map<String, dynamic> json) =>
      _$SemesterListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SemesterDto {
  const SemesterDto({
    this.id,
    this.semesterId,
    this.name,
    this.description,
    this.displayOrder,
    this.imageUrl,
    this.createDt,
    this.modifyDt,
  });

  @JsonKey(fromJson: _intFromJson)
  final int? id;
  @JsonKey(fromJson: _intFromJson)
  final int? semesterId;
  final String? name;
  final String? description;
  @JsonKey(fromJson: _intFromJson)
  final int? displayOrder;
  final String? imageUrl;
  final String? createDt;
  final String? modifyDt;

  factory SemesterDto.fromJson(Map<String, dynamic> json) =>
      _$SemesterDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterDtoToJson(this);
}

List<SemesterDto> _semesterListFromJson(Object? value) {
  return _listFromJson(value, SemesterDto.fromJson);
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
