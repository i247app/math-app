class ProfileListRequest {
  const ProfileListRequest({required this.userId});

  final String userId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'user_id': userId};
  }
}

class ProgramListRequest {
  const ProgramListRequest({required this.userId});

  final String userId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'user_id': userId};
  }
}

class SemesterListRequest {
  const SemesterListRequest({required this.userId});

  final String userId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'user_id': userId};
  }
}

class CreateProfileRequest {
  const CreateProfileRequest({
    required this.userId,
    required this.name,
    required this.gradeId,
    required this.programId,
    required this.semesterId,
    this.dob,
  });

  final String userId;
  final String name;
  final String gradeId;
  final String programId;
  final String semesterId;
  final String? dob;
}

class ProfileListResponse {
  const ProfileListResponse({
    required this.mstatus,
    this.profiles = const <StudentProfile>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final List<StudentProfile> profiles;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ProfileListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final profilesValue =
        json['profiles'] ?? _nestedValue(data, 'profiles') ?? json['profile'];

    return ProfileListResponse(
      mstatus: _intFromJson(json['mstatus']) ?? 0,
      profiles: _profilesFromJson(profilesValue),
      status: json['status'] as String?,
      mmessage: json['mmessage'] as String?,
      debug: json['debug'] as String?,
    );
  }
}

class ProgramListResponse {
  const ProgramListResponse({
    required this.mstatus,
    this.programs = const <ProfileProgram>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final List<ProfileProgram> programs;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ProgramListResponse.fromJson(Map<String, dynamic> json) {
    return ProgramListResponse(
      mstatus: _intFromJson(json['mstatus']) ?? 0,
      programs: _listFromJson(json['programs'], ProfileProgram.fromJson),
      status: json['status'] as String?,
      mmessage: json['mmessage'] as String?,
      debug: json['debug'] as String?,
    );
  }
}

class SemesterListResponse {
  const SemesterListResponse({
    required this.mstatus,
    this.semesters = const <ProfileSemester>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final List<ProfileSemester> semesters;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory SemesterListResponse.fromJson(Map<String, dynamic> json) {
    return SemesterListResponse(
      mstatus: _intFromJson(json['mstatus']) ?? 0,
      semesters: _listFromJson(json['semesters'], ProfileSemester.fromJson),
      status: json['status'] as String?,
      mmessage: json['mmessage'] as String?,
      debug: json['debug'] as String?,
    );
  }
}

class CreateProfileResponse {
  const CreateProfileResponse({
    required this.mstatus,
    this.profile,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final StudentProfile? profile;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory CreateProfileResponse.fromJson(Map<String, dynamic> json) {
    return CreateProfileResponse(
      mstatus: _intFromJson(json['mstatus']) ?? 0,
      profile: _objectFromJson(json['profile'], StudentProfile.fromJson),
      status: json['status'] as String?,
      mmessage: json['mmessage'] as String?,
      debug: json['debug'] as String?,
    );
  }
}

class StudentProfile {
  const StudentProfile({
    this.id,
    this.profileId,
    this.userId,
    this.name,
    this.avatarKey,
    this.avatarUrl,
    this.dob,
    this.gradeId,
    this.grade,
    this.programId,
    this.program,
    this.semesterId,
    this.semester,
    this.isDefault = false,
    this.createDt,
    this.modifyDt,
  });

  final String? id;
  final String? profileId;
  final String? userId;
  final String? name;
  final String? avatarKey;
  final String? avatarUrl;
  final String? dob;
  final String? gradeId;
  final ProfileGrade? grade;
  final String? programId;
  final ProfileProgram? program;
  final String? semesterId;
  final ProfileSemester? semester;
  final bool isDefault;
  final String? createDt;
  final String? modifyDt;

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id']?.toString(),
      profileId: json['profile_id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String?,
      avatarKey: json['avatar_key'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      dob: json['dob'] as String?,
      gradeId: json['grade_id'] as String?,
      grade: _objectFromJson(json['grade'], ProfileGrade.fromJson),
      programId: json['program_id'] as String?,
      program: _objectFromJson(json['program'], ProfileProgram.fromJson),
      semesterId: json['semester_id'] as String?,
      semester: _objectFromJson(json['semester'], ProfileSemester.fromJson),
      isDefault: json['is_default'] == true,
      createDt: json['create_dt'] as String?,
      modifyDt: json['modify_dt'] as String?,
    );
  }
}

class ProfileGrade {
  const ProfileGrade({
    this.id,
    this.gradeId,
    this.label,
    this.description,
    this.displayOrder,
    this.imageUrl,
  });

  final String? id;
  final String? gradeId;
  final String? label;
  final String? description;
  final int? displayOrder;
  final String? imageUrl;

  factory ProfileGrade.fromJson(Map<String, dynamic> json) {
    return ProfileGrade(
      id: json['id']?.toString(),
      gradeId: json['grade_id'] as String?,
      label: json['label'] as String?,
      description: json['description'] as String?,
      displayOrder: _intFromJson(json['display_order']),
      imageUrl: json['image_url'] as String?,
    );
  }
}

class ProfileProgram {
  const ProfileProgram({
    this.id,
    this.programId,
    this.label,
    this.description,
    this.displayOrder,
    this.imageUrl,
  });

  final String? id;
  final String? programId;
  final String? label;
  final String? description;
  final int? displayOrder;
  final String? imageUrl;

  factory ProfileProgram.fromJson(Map<String, dynamic> json) {
    return ProfileProgram(
      id: json['id']?.toString(),
      programId: json['program_id'] as String?,
      label: json['label'] as String?,
      description: json['description'] as String?,
      displayOrder: _intFromJson(json['display_order']),
      imageUrl: json['image_url'] as String?,
    );
  }
}

class ProfileSemester {
  const ProfileSemester({
    this.id,
    this.semesterId,
    this.name,
    this.description,
    this.displayOrder,
    this.imageUrl,
  });

  final String? id;
  final String? semesterId;
  final String? name;
  final String? description;
  final int? displayOrder;
  final String? imageUrl;

  factory ProfileSemester.fromJson(Map<String, dynamic> json) {
    return ProfileSemester(
      id: json['id']?.toString(),
      semesterId: json['semester_id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      displayOrder: _intFromJson(json['display_order']),
      imageUrl: json['image_url'] as String?,
    );
  }
}

List<StudentProfile> _profilesFromJson(Object? value) {
  if (value is List) {
    return value
        .map((item) => _objectFromJson(item, StudentProfile.fromJson))
        .whereType<StudentProfile>()
        .toList();
  }

  final profile = _objectFromJson(value, StudentProfile.fromJson);
  return profile == null ? const <StudentProfile>[] : <StudentProfile>[profile];
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

Object? _nestedValue(Object? value, String key) {
  if (value case final Map<String, dynamic> json) {
    return json[key];
  }
  if (value case final Map<Object?, Object?> json) {
    return json[key];
  }
  return null;
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
