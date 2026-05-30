import 'package:json_annotation/json_annotation.dart';

part 'classroom_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomListRequest {
  const ClassroomListRequest({required this.profileId});

  final String profileId;

  factory ClassroomListRequest.fromJson(Map<String, dynamic> json) =>
      _$ClassroomListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class CreateClassroomRequest {
  const CreateClassroomRequest({
    required this.profileId,
    required this.name,
    required this.programId,
    required this.gradeId,
    required this.schoolId,
    this.description,
    this.maxMembers = 50,
  });

  final String profileId;
  final String name;
  final String programId;
  final String gradeId;
  final String schoolId;
  final String? description;
  @JsonKey(fromJson: _requiredIntFromJson)
  final int maxMembers;

  factory CreateClassroomRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateClassroomRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateClassroomRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ClassroomListResponse {
  const ClassroomListResponse({
    required this.mstatus,
    this.classrooms = const <ClassroomModel>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _classroomListFromJson)
  final List<ClassroomModel> classrooms;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ClassroomListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final classroomsValue = json['classrooms'] ??
        json['classes'] ??
        json['items'] ??
        _nestedValue(data, 'classrooms') ??
        _nestedValue(data, 'classes') ??
        _nestedValue(data, 'items') ??
        data;

    return _$ClassroomListResponseFromJson(
      <String, dynamic>{
        ...json,
        'classrooms': classroomsValue,
      },
    );
  }

  Map<String, dynamic> toJson() => _$ClassroomListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ClassroomResponse {
  const ClassroomResponse({
    required this.mstatus,
    this.classroom,
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _classroomFromJson)
  final ClassroomModel? classroom;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ClassroomResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final classroomValue = json['classroom'] ??
        json['class'] ??
        _nestedValue(data, 'classroom') ??
        _nestedValue(data, 'class') ??
        data;

    return _$ClassroomResponseFromJson(
      <String, dynamic>{
        ...json,
        'classroom': classroomValue,
      },
    );
  }

  Map<String, dynamic> toJson() => _$ClassroomResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ClassroomModel {
  const ClassroomModel({
    this.id,
    this.classroomId,
    this.profileId,
    this.name,
    this.description,
    this.programId,
    this.gradeId,
    this.schoolId,
    this.inviteCode,
    this.maxMembers,
    this.memberCount,
    this.students = const <ClassroomStudent>[],
    this.imageUrl,
    this.avatarUrl,
    this.fileUrl,
    this.createDt,
    this.modifyDt,
  });

  @JsonKey(fromJson: _stringFromJson)
  final String? id;
  final String? classroomId;
  final String? profileId;
  final String? name;
  final String? description;
  final String? programId;
  final String? gradeId;
  final String? schoolId;
  @JsonKey(fromJson: _stringFromJson)
  final String? inviteCode;
  @JsonKey(fromJson: _intFromJson)
  final int? maxMembers;
  @JsonKey(fromJson: _intFromJson)
  final int? memberCount;
  @JsonKey(fromJson: _studentListFromJson)
  final List<ClassroomStudent> students;
  final String? imageUrl;
  final String? avatarUrl;
  final String? fileUrl;
  final String? createDt;
  final String? modifyDt;

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    final studentsValue = json['students'] ??
        json['members'] ??
        json['student_profiles'] ??
        _nestedValue(json['data'], 'students');
    final memberCountValue = json['member_count'] ??
        json['members_count'] ??
        json['student_count'] ??
        json['students_count'] ??
        (studentsValue is List ? studentsValue.length : null);

    return _$ClassroomModelFromJson(
      <String, dynamic>{
        ...json,
        'students': studentsValue,
        'member_count': memberCountValue,
      },
    );
  }

  Map<String, dynamic> toJson() => _$ClassroomModelToJson(this);

  String? get stableId {
    final candidate = classroomId?.trim();
    if (candidate != null && candidate.isNotEmpty) {
      return candidate;
    }
    final fallback = id?.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    return null;
  }

  int get displayMemberCount =>
      memberCount ?? (students.isNotEmpty ? students.length : 0);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomStudent {
  const ClassroomStudent({
    this.id,
    this.profileId,
    this.name,
    this.avatarUrl,
    this.joinedAt,
    this.status,
  });

  @JsonKey(fromJson: _stringFromJson)
  final String? id;
  final String? profileId;
  final String? name;
  final String? avatarUrl;
  final String? joinedAt;
  final String? status;

  factory ClassroomStudent.fromJson(Map<String, dynamic> json) =>
      _$ClassroomStudentFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomStudentToJson(this);
}

List<ClassroomModel> _classroomListFromJson(Object? value) {
  return _listFromJson(value, ClassroomModel.fromJson);
}

ClassroomModel? _classroomFromJson(Object? value) {
  return _objectFromJson(value, ClassroomModel.fromJson);
}

List<ClassroomStudent> _studentListFromJson(Object? value) {
  return _listFromJson(value, ClassroomStudent.fromJson);
}

Object? _nestedValue(Object? value, String key) {
  if (value case final Map<String, dynamic> json) {
    return json[key];
  }
  if (value case final Map<Object?, Object?> json) {
    return json[key];
  }
  return null;
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

String? _stringFromJson(Object? value) => value?.toString();
