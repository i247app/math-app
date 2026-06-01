import 'package:json_annotation/json_annotation.dart';

part 'classroom_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomListRequest {
  const ClassroomListRequest({required this.profileId});

  final int profileId;

  factory ClassroomListRequest.fromJson(Map<String, dynamic> json) =>
      _$ClassroomListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ClassroomMembersListRequest {
  const ClassroomMembersListRequest({
    required this.profileId,
    required this.classroomId,
    this.role,
    this.status,
  });

  final int profileId;
  final int classroomId;
  final String? role;
  final String? status;

  factory ClassroomMembersListRequest.fromJson(Map<String, dynamic> json) =>
      _$ClassroomMembersListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomMembersListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomJoinRequestActionRequest {
  const ClassroomJoinRequestActionRequest({
    required this.profileId,
    required this.classroomId,
    required this.targetProfileId,
  });

  final int profileId;
  final int classroomId;
  final int targetProfileId;

  factory ClassroomJoinRequestActionRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$ClassroomJoinRequestActionRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClassroomJoinRequestActionRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class CreateClassroomRequest {
  const CreateClassroomRequest({
    required this.profileId,
    required this.name,
    required this.programIds,
    required this.gradeId,
    required this.schoolId,
    this.description,
    this.maxMembers = 50,
  });

  final int profileId;
  final String name;
  @JsonKey(defaultValue: <int>[])
  final List<int> programIds;
  final int gradeId;
  final int schoolId;
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
class ClassroomMemberListResponse {
  const ClassroomMemberListResponse({
    required this.mstatus,
    this.members = const <ClassroomStudent>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _studentListFromJson)
  final List<ClassroomStudent> members;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ClassroomMemberListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final membersValue = json['members'] ??
        json['students'] ??
        json['profiles'] ??
        json['items'] ??
        json['join_requests'] ??
        json['requests'] ??
        _nestedValue(data, 'members') ??
        _nestedValue(data, 'students') ??
        _nestedValue(data, 'profiles') ??
        _nestedValue(data, 'items') ??
        _nestedValue(data, 'join_requests') ??
        _nestedValue(data, 'requests') ??
        data;

    return _$ClassroomMemberListResponseFromJson(
      <String, dynamic>{
        ...json,
        'members': membersValue,
      },
    );
  }

  Map<String, dynamic> toJson() => _$ClassroomMemberListResponseToJson(this);
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

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomActionResponse {
  const ClassroomActionResponse({
    required this.mstatus,
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ClassroomActionResponse.fromJson(Map<String, dynamic> json) =>
      _$ClassroomActionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomActionResponseToJson(this);
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
    this.classroomCode,
    this.maxMembers,
    this.memberCount,
    this.studentCount,
    this.students = const <ClassroomStudent>[],
    this.imageUrl,
    this.avatarUrl,
    this.fileUrl,
    this.createDt,
    this.modifyDt,
  });

  @JsonKey(fromJson: _intFromJson)
  final int? id;
  @JsonKey(fromJson: _intFromJson)
  final int? classroomId;
  @JsonKey(fromJson: _intFromJson)
  final int? profileId;
  final String? name;
  final String? description;
  @JsonKey(fromJson: _intFromJson)
  final int? programId;
  @JsonKey(fromJson: _intFromJson)
  final int? gradeId;
  @JsonKey(fromJson: _intFromJson)
  final int? schoolId;
  @JsonKey(fromJson: _stringFromJson)
  final String? classroomCode;
  @JsonKey(fromJson: _intFromJson)
  final int? maxMembers;
  @JsonKey(fromJson: _intFromJson)
  final int? memberCount;
  @JsonKey(fromJson: _intFromJson)
  final int? studentCount;
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
    final memberCountValue = json['member_count'] ?? json['members_count'];
    final studentCountValue = json['student_count'] ??
        json['students_count'] ??
        (studentsValue is List ? studentsValue.length : null);

    return _$ClassroomModelFromJson(
      <String, dynamic>{
        ...json,
        'classroom_code': json['classroom_code'] ?? json['invite_code'],
        'students': studentsValue,
        'member_count': memberCountValue,
        'student_count': studentCountValue,
      },
    );
  }

  Map<String, dynamic> toJson() => _$ClassroomModelToJson(this);

  int? get stableId => classroomId ?? id;

  int get displayStudentCount =>
      studentCount ?? (students.isNotEmpty ? students.length : 0);

  int get displayMemberCount => memberCount ?? displayStudentCount;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomStudent {
  const ClassroomStudent({
    this.id,
    this.profileId,
    this.name,
    this.avatarKey,
    this.avatarUrl,
    this.joinedAt,
    this.status,
    this.role,
  });

  @JsonKey(fromJson: _intFromJson)
  final int? id;
  @JsonKey(fromJson: _intFromJson)
  final int? profileId;
  final String? name;
  final String? avatarKey;
  final String? avatarUrl;
  final String? joinedAt;
  final String? status;
  final String? role;

  factory ClassroomStudent.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    final user = json['user'];
    final profileId = json['profile_id'] ??
        json['target_profile_id'] ??
        json['student_profile_id'] ??
        _nestedValue(profile, 'id') ??
        _nestedValue(profile, 'profile_id');
    final name = json['name'] ??
        json['profile_name'] ??
        json['student_name'] ??
        _nestedValue(profile, 'name') ??
        _nestedValue(user, 'name');
    final avatarKey = json['avatar_key'] ?? _nestedValue(profile, 'avatar_key');
    final avatarUrl = json['avatar_url'] ??
        json['profile_avatar_url'] ??
        _nestedValue(profile, 'avatar_url') ??
        _nestedValue(user, 'avatar_url');
    final role = json['role'] ?? _nestedValue(profile, 'role');

    return _$ClassroomStudentFromJson(
      <String, dynamic>{
        ...json,
        'profile_id': profileId,
        'name': name,
        'avatar_key': avatarKey,
        'avatar_url': avatarUrl,
        'role': role,
      },
    );
  }

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
