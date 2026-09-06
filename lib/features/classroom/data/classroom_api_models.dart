import 'package:json_annotation/json_annotation.dart';

part 'classroom_api_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ClassroomListRequest {
  const ClassroomListRequest({
    required this.profileId,
    this.ownerProfileId,
    this.search,
    this.gradeIds,
    this.schoolIds,
  });

  final int profileId;
  final int? ownerProfileId;
  final String? search;
  final List<int>? gradeIds;
  final List<int>? schoolIds;

  factory ClassroomListRequest.fromJson(Map<String, dynamic> json) =>
      _$ClassroomListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomJoinByCodeRequest {
  const ClassroomJoinByCodeRequest({
    required this.profileId,
    required this.classroomCode,
  });

  final int profileId;
  final String classroomCode;

  factory ClassroomJoinByCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$ClassroomJoinByCodeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomJoinByCodeRequestToJson(this);
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
  ) => _$ClassroomJoinRequestActionRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClassroomJoinRequestActionRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomInvitationSendRequest {
  const ClassroomInvitationSendRequest({
    required this.inviterProfileId,
    required this.classroomId,
    required this.targets,
  });

  final int inviterProfileId;
  final int classroomId;
  @JsonKey(defaultValue: <int>[])
  final List<int> targets;

  factory ClassroomInvitationSendRequest.fromJson(Map<String, dynamic> json) =>
      _$ClassroomInvitationSendRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomInvitationSendRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomInvitationListRequest {
  const ClassroomInvitationListRequest({required this.profileId});

  final int profileId;

  factory ClassroomInvitationListRequest.fromJson(Map<String, dynamic> json) =>
      _$ClassroomInvitationListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomInvitationListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomInvitationActionRequest {
  const ClassroomInvitationActionRequest({
    required this.inviteeProfileId,
    required this.inviterProfileId,
    required this.classroomId,
  });

  final int inviteeProfileId;
  final int inviterProfileId;
  final int classroomId;

  factory ClassroomInvitationActionRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$ClassroomInvitationActionRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClassroomInvitationActionRequestToJson(this);
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
    this.classrooms = const <ClassroomDto>[],
    this.pagination,
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _classroomListFromJson)
  final List<ClassroomDto> classrooms;
  final ClassroomPagination? pagination;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ClassroomListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final classroomsValue =
        json['classrooms'] ??
        json['classes'] ??
        json['items'] ??
        _nestedValue(data, 'classrooms') ??
        _nestedValue(data, 'classes') ??
        _nestedValue(data, 'items') ??
        data;

    return _$ClassroomListResponseFromJson(<String, dynamic>{
      ...json,
      'classrooms': classroomsValue,
    });
  }

  Map<String, dynamic> toJson() => _$ClassroomListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomPagination {
  const ClassroomPagination({
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

  factory ClassroomPagination.fromJson(Map<String, dynamic> json) =>
      _$ClassroomPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomPaginationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ClassroomMemberListResponse {
  const ClassroomMemberListResponse({
    required this.mstatus,
    this.members = const <ClassroomStudentDto>[],
    this.pagination,
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _studentListFromJson)
  final List<ClassroomStudentDto> members;
  final ClassroomPagination? pagination;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ClassroomMemberListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final membersValue =
        json['members'] ??
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

    return _$ClassroomMemberListResponseFromJson(<String, dynamic>{
      ...json,
      'members': membersValue,
    });
  }

  Map<String, dynamic> toJson() => _$ClassroomMemberListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ClassroomInvitationListResponse {
  const ClassroomInvitationListResponse({
    required this.mstatus,
    this.invitations = const <ClassroomInvitationDto>[],
    this.pagination,
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _invitationListFromJson)
  final List<ClassroomInvitationDto> invitations;
  final ClassroomPagination? pagination;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ClassroomInvitationListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final invitationsValue =
        json['invitations'] ??
        json['classroom_invitations'] ??
        json['items'] ??
        json['classes'] ??
        json['classrooms'] ??
        _nestedValue(data, 'invitations') ??
        _nestedValue(data, 'classroom_invitations') ??
        _nestedValue(data, 'items') ??
        _nestedValue(data, 'classes') ??
        _nestedValue(data, 'classrooms') ??
        data;

    return _$ClassroomInvitationListResponseFromJson(<String, dynamic>{
      ...json,
      'invitations': invitationsValue,
    });
  }

  Map<String, dynamic> toJson() =>
      _$ClassroomInvitationListResponseToJson(this);
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
  final ClassroomDto? classroom;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ClassroomResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final classroomValue =
        json['classroom'] ??
        json['class'] ??
        _nestedValue(data, 'classroom') ??
        _nestedValue(data, 'class') ??
        data;

    return _$ClassroomResponseFromJson(<String, dynamic>{
      ...json,
      'classroom': classroomValue,
    });
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
class ClassroomDto {
  const ClassroomDto({
    this.id,
    this.classroomId,
    this.profileId,
    this.name,
    this.description,
    this.programId,
    this.programIds = const <int>[],
    this.gradeId,
    this.schoolId,
    this.classroomCode,
    this.owner,
    this.ownerProfileId,
    this.relationship,
    this.teacherName,
    this.programName,
    this.schoolName,
    this.maxMembers,
    this.memberCount,
    this.studentCount,
    this.teacherCount,
    this.pendingRequestCount,
    this.students = const <ClassroomStudentDto>[],
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
  @JsonKey(fromJson: _intListFromJson)
  final List<int> programIds;
  @JsonKey(fromJson: _intFromJson)
  final int? gradeId;
  @JsonKey(fromJson: _intFromJson)
  final int? schoolId;
  @JsonKey(fromJson: _stringFromJson)
  final String? classroomCode;
  @JsonKey(fromJson: _ownerFromJson)
  final ClassroomOwnerDto? owner;
  @JsonKey(fromJson: _intFromJson)
  final int? ownerProfileId;
  @JsonKey(fromJson: _stringFromJson)
  final String? relationship;
  @JsonKey(fromJson: _stringFromJson)
  final String? teacherName;
  @JsonKey(fromJson: _stringFromJson)
  final String? programName;
  @JsonKey(fromJson: _stringFromJson)
  final String? schoolName;
  @JsonKey(fromJson: _intFromJson)
  final int? maxMembers;
  @JsonKey(fromJson: _intFromJson)
  final int? memberCount;
  @JsonKey(fromJson: _intFromJson)
  final int? studentCount;
  @JsonKey(fromJson: _intFromJson)
  final int? teacherCount;
  @JsonKey(fromJson: _intFromJson)
  final int? pendingRequestCount;
  @JsonKey(fromJson: _studentListFromJson)
  final List<ClassroomStudentDto> students;
  final String? imageUrl;
  final String? avatarUrl;
  final String? fileUrl;
  final String? createDt;
  final String? modifyDt;

  factory ClassroomDto.fromJson(Map<String, dynamic> json) {
    final studentsValue =
        json['students'] ??
        json['members'] ??
        json['student_profiles'] ??
        _nestedValue(json['data'], 'students');
    final memberCountValue = json['member_count'] ?? json['members_count'];
    final studentCountValue =
        json['student_count'] ??
        json['students_count'] ??
        (studentsValue is List ? studentsValue.length : null);
    final pendingRequestCountValue =
        json['pending_request_count'] ??
        json['pending_requests_count'] ??
        json['join_request_count'] ??
        json['join_requests_count'];

    return _$ClassroomDtoFromJson(<String, dynamic>{
      ...json,
      'classroom_code': json['classroom_code'] ?? json['invite_code'],
      'program_ids':
          json['program_ids'] ??
          json['programIds'] ??
          (json['program_id'] == null ? null : <Object?>[json['program_id']]),
      'owner_profile_id':
          json['owner_profile_id'] ??
          _nestedValue(json['owner'], 'profile_id') ??
          _nestedValue(json['teacher'], 'profile_id'),
      'owner': json['owner'] ?? json['teacher'],
      'teacher_name':
          json['teacher_name'] ??
          json['owner_name'] ??
          _nestedValue(json['owner'], 'name') ??
          _nestedValue(json['teacher'], 'name') ??
          _nestedValue(json['profile'], 'name'),
      'program_name':
          json['program_name'] ??
          json['program_label'] ??
          _nestedValue(json['program'], 'label') ??
          _nestedValue(json['program'], 'name'),
      'school_name':
          json['school_name'] ?? _nestedValue(json['school'], 'name'),
      'students': studentsValue,
      'member_count': memberCountValue,
      'student_count': studentCountValue,
      'pending_request_count': pendingRequestCountValue,
    });
  }

  Map<String, dynamic> toJson() => _$ClassroomDtoToJson(this);

  int? get stableId => classroomId ?? id;

  int get displayStudentCount =>
      studentCount ?? (students.isNotEmpty ? students.length : 0);

  int get displayMemberCount => memberCount ?? displayStudentCount;

  int get displayPendingRequestCount => pendingRequestCount ?? 0;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomOwnerDto {
  const ClassroomOwnerDto({
    this.profileId,
    this.name,
    this.role,
    this.avatarUrl,
    this.imageUrl,
    this.fileUrl,
  });

  @JsonKey(fromJson: _intFromJson)
  final int? profileId;
  final String? name;
  final String? role;
  @JsonKey(fromJson: _stringFromJson)
  final String? avatarUrl;
  @JsonKey(fromJson: _stringFromJson)
  final String? imageUrl;
  @JsonKey(fromJson: _stringFromJson)
  final String? fileUrl;

  factory ClassroomOwnerDto.fromJson(Map<String, dynamic> json) {
    return _$ClassroomOwnerDtoFromJson(<String, dynamic>{
      ...json,
      'avatar_url':
          json['avatar_url'] ??
          json['profile_avatar_url'] ??
          _nestedValue(json['profile'], 'avatar_url') ??
          _nestedValue(json['user'], 'avatar_url'),
      'image_url':
          json['image_url'] ??
          json['profile_image_url'] ??
          _nestedValue(json['profile'], 'image_url') ??
          _nestedValue(json['user'], 'image_url'),
      'file_url':
          json['file_url'] ??
          json['profile_file_url'] ??
          _nestedValue(json['profile'], 'file_url') ??
          _nestedValue(json['user'], 'file_url'),
    });
  }

  Map<String, dynamic> toJson() => _$ClassroomOwnerDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassroomStudentDto {
  const ClassroomStudentDto({
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

  factory ClassroomStudentDto.fromJson(Map<String, dynamic> json) {
    final requester = json['requester'];
    final memberProfile = json['member_profile'];
    final profile = json['profile'];
    final user = json['user'];
    final id = json['id'] ?? json['request_id'] ?? json['member_id'];
    final profileId =
        json['profile_id'] ??
        _nestedValue(requester, 'profile_id') ??
        _nestedValue(requester, 'id') ??
        _nestedValue(memberProfile, 'profile_id') ??
        _nestedValue(memberProfile, 'id') ??
        json['target_profile_id'] ??
        json['student_profile_id'] ??
        _nestedValue(profile, 'id') ??
        _nestedValue(profile, 'profile_id');
    final name =
        json['name'] ??
        _nestedValue(requester, 'name') ??
        _nestedValue(memberProfile, 'name') ??
        json['profile_name'] ??
        json['student_name'] ??
        _nestedValue(profile, 'name') ??
        _nestedValue(user, 'name');
    final avatarKey =
        json['avatar_key'] ??
        _nestedValue(requester, 'avatar_key') ??
        _nestedValue(memberProfile, 'avatar_key') ??
        _nestedValue(profile, 'avatar_key');
    final avatarUrl =
        json['avatar_url'] ??
        _nestedValue(requester, 'avatar_url') ??
        _nestedValue(memberProfile, 'avatar_url') ??
        json['profile_avatar_url'] ??
        _nestedValue(profile, 'avatar_url') ??
        _nestedValue(user, 'avatar_url');
    final role =
        json['role'] ??
        json['member_role'] ??
        _nestedValue(requester, 'role') ??
        _nestedValue(memberProfile, 'role') ??
        _nestedValue(profile, 'role');
    final status = json['status'] ?? json['member_status'];
    final joinedAt = json['joined_at'] ?? json['joined_dt'];

    return _$ClassroomStudentDtoFromJson(<String, dynamic>{
      ...json,
      'id': id,
      'profile_id': profileId,
      'name': name,
      'avatar_key': avatarKey,
      'avatar_url': avatarUrl,
      'role': role,
      'status': status,
      'joined_at': joinedAt,
    });
  }

  Map<String, dynamic> toJson() => _$ClassroomStudentDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ClassroomInvitationDto {
  const ClassroomInvitationDto({
    this.id,
    this.invitationId,
    this.classroomId,
    this.inviterProfileId,
    this.inviterName,
    this.status,
    this.createdAt,
    this.classroom,
  });

  @JsonKey(fromJson: _intFromJson)
  final int? id;
  @JsonKey(fromJson: _intFromJson)
  final int? invitationId;
  @JsonKey(fromJson: _intFromJson)
  final int? classroomId;
  @JsonKey(fromJson: _intFromJson)
  final int? inviterProfileId;
  @JsonKey(fromJson: _stringFromJson)
  final String? inviterName;
  @JsonKey(fromJson: _stringFromJson)
  final String? status;
  @JsonKey(fromJson: _stringFromJson)
  final String? createdAt;
  @JsonKey(fromJson: _classroomFromJson)
  final ClassroomDto? classroom;

  factory ClassroomInvitationDto.fromJson(Map<String, dynamic> json) {
    final classroom = json['classroom'] ?? json['class'];
    final inviter = json['inviter'] ?? json['teacher'] ?? json['owner'];
    final classroomId =
        json['classroom_id'] ??
        _nestedValue(classroom, 'classroom_id') ??
        _nestedValue(classroom, 'id');
    final inviterProfileId =
        json['inviter_profile_id'] ??
        json['teacher_profile_id'] ??
        json['owner_profile_id'] ??
        _nestedValue(inviter, 'profile_id') ??
        _nestedValue(classroom, 'owner_profile_id');
    final classroomValue =
        classroom ?? <String, dynamic>{...json, 'classroom_id': classroomId};

    return _$ClassroomInvitationDtoFromJson(<String, dynamic>{
      ...json,
      'invitation_id': json['invitation_id'] ?? json['request_id'],
      'classroom_id': classroomId,
      'inviter_profile_id': inviterProfileId,
      'inviter_name':
          json['inviter_name'] ??
          json['teacher_name'] ??
          _nestedValue(inviter, 'name') ??
          _nestedValue(classroom, 'teacher_name'),
      'created_at':
          json['created_at'] ??
          json['created_dt'] ??
          json['invited_dt'] ??
          json['requested_dt'],
      'classroom': classroomValue,
    });
  }

  Map<String, dynamic> toJson() => _$ClassroomInvitationDtoToJson(this);

  int? get stableClassroomId => classroomId ?? classroom?.stableId;
}

List<ClassroomDto> _classroomListFromJson(Object? value) {
  return _listFromJson(value, ClassroomDto.fromJson);
}

List<ClassroomInvitationDto> _invitationListFromJson(Object? value) {
  return _listFromJson(value, ClassroomInvitationDto.fromJson);
}

ClassroomDto? _classroomFromJson(Object? value) {
  return _objectFromJson(value, ClassroomDto.fromJson);
}

ClassroomOwnerDto? _ownerFromJson(Object? value) {
  return _objectFromJson(value, ClassroomOwnerDto.fromJson);
}

List<ClassroomStudentDto> _studentListFromJson(Object? value) {
  return _listFromJson(value, ClassroomStudentDto.fromJson);
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

List<int> _intListFromJson(Object? value) {
  if (value is! List) {
    return const <int>[];
  }
  return value.map(_intFromJson).whereType<int>().toList();
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

String? _stringFromJson(Object? value) => value?.toString();
