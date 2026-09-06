import 'package:json_annotation/json_annotation.dart';

part 'program_api_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProgramListRequest {
  const ProgramListRequest({required this.userId});

  final int userId;

  factory ProgramListRequest.fromJson(Map<String, dynamic> json) =>
      _$ProgramListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ProgramListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ProgramListResponse {
  const ProgramListResponse({
    required this.mstatus,
    this.programs = const <ProgramDto>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _programListFromJson)
  final List<ProgramDto> programs;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ProgramListResponse.fromJson(Map<String, dynamic> json) =>
      _$ProgramListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProgramListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ProgramDto {
  const ProgramDto({
    this.id,
    this.programId,
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
  final int? programId;
  final String? label;
  final String? description;
  @JsonKey(fromJson: _intFromJson)
  final int? displayOrder;
  final String? imageUrl;
  final String? createDt;
  final String? modifyDt;

  factory ProgramDto.fromJson(Map<String, dynamic> json) =>
      _$ProgramDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProgramDtoToJson(this);
}

List<ProgramDto> _programListFromJson(Object? value) {
  return _listFromJson(value, ProgramDto.fromJson);
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
