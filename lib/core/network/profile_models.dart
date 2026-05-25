import 'program_models.dart';
import 'semester_models.dart';

class ProfileListRequest {
  const ProfileListRequest({required this.userId});

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

class UpdateProfileRequest {
  const UpdateProfileRequest({
    required this.profileId,
    required this.name,
    required this.gradeId,
    required this.programId,
    required this.semesterId,
    this.dob,
  });

  final String profileId;
  final String name;
  final String gradeId;
  final String programId;
  final String semesterId;
  final String? dob;
}

class DeleteProfileRequest {
  const DeleteProfileRequest({required this.profileId});

  final String profileId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'metadata': _profileMetadata,
      'profile_id': profileId,
    };
  }
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

class UpdateProfileResponse {
  const UpdateProfileResponse({
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

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      mstatus: _intFromJson(json['mstatus']) ?? 0,
      profile: _objectFromJson(json['profile'], StudentProfile.fromJson),
      status: json['status'] as String?,
      mmessage: json['mmessage'] as String?,
      debug: json['debug'] as String?,
    );
  }
}

class DeleteProfileResponse {
  const DeleteProfileResponse({
    required this.mstatus,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory DeleteProfileResponse.fromJson(Map<String, dynamic> json) {
    return DeleteProfileResponse(
      mstatus: _intFromJson(json['mstatus']) ?? 0,
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
  final ProgramModel? program;
  final String? semesterId;
  final SemesterModel? semester;
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
      program: _objectFromJson(json['program'], ProgramModel.fromJson),
      semesterId: json['semester_id'] as String?,
      semester: _objectFromJson(json['semester'], SemesterModel.fromJson),
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

const _profileMetadata = <String, Object>{
  'client_info': <String, String>{
    'platform': 'ios',
    'app_version': '2.1.0',
    'device_id': '18092003-18092003-18092003-18092003',
    'device_name': 'MACBOOK-PRO-M4',
    'device_push_token': 'ABCDE',
    'ip_address': '42.118.191.193',
  },
};
