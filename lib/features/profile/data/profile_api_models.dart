import 'package:json_annotation/json_annotation.dart';

import 'school_api_models.dart';
import 'program_api_models.dart';
import 'semester_api_models.dart';

part 'profile_api_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ProfileListRequest {
  const ProfileListRequest({this.userId, this.search});

  final int? userId;
  final String? search;

  factory ProfileListRequest.fromJson(Map<String, dynamic> json) =>
      _$ProfileListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class CreateProfileRequest {
  const CreateProfileRequest({
    required this.userId,
    required this.schoolId,
    required this.name,
    this.gradeId,
    this.programId,
    this.semesterId,
    this.isDefault = false,
    this.role = 'STUDENT',
    this.dob,
    this.avatarKey,
    this.idType,
    this.studentId,
    this.teacherId,
  });

  final int userId;
  final int schoolId;
  final String name;
  final int? gradeId;
  final int? programId;
  final int? semesterId;
  final bool isDefault;
  final String role;
  final String? dob;
  final String? avatarKey;
  final String? idType;
  final String? studentId;
  final String? teacherId;

  factory CreateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateProfileRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class UpdateProfileRequest {
  const UpdateProfileRequest({
    required this.profileId,
    this.schoolId,
    this.name,
    this.gradeId,
    this.programId,
    this.semesterId,
    this.isDefault,
    this.role,
    this.dob,
    this.avatarKey,
    this.idType,
    this.studentId,
    this.teacherId,
  });

  final int profileId;
  final int? schoolId;
  final String? name;
  final int? gradeId;
  final int? programId;
  final int? semesterId;
  final bool? isDefault;
  final String? role;
  final String? dob;
  final String? avatarKey;
  final String? idType;
  final String? studentId;
  final String? teacherId;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class DeleteProfileRequest {
  const DeleteProfileRequest({required this.profileId});

  final int profileId;

  factory DeleteProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$DeleteProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteProfileRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ProfileListResponse {
  const ProfileListResponse({
    required this.mstatus,
    this.profiles = const <StudentProfileDto>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _profilesFromJson)
  final List<StudentProfileDto> profiles;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ProfileListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final profilesValue =
        json['profiles'] ?? _nestedValue(data, 'profiles') ?? json['profile'];

    return _$ProfileListResponseFromJson(<String, dynamic>{
      ...json,
      'profiles': profilesValue,
    });
  }

  Map<String, dynamic> toJson() => _$ProfileListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CreateProfileResponse {
  const CreateProfileResponse({
    required this.mstatus,
    this.profile,
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _studentProfileFromJson)
  final StudentProfileDto? profile;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory CreateProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateProfileResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class UpdateProfileResponse {
  const UpdateProfileResponse({
    required this.mstatus,
    this.profile,
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _studentProfileFromJson)
  final StudentProfileDto? profile;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DeleteProfileResponse {
  const DeleteProfileResponse({
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

  factory DeleteProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteProfileResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class StudentProfileDto {
  const StudentProfileDto({
    this.id,
    this.profileId,
    this.profileCode,
    this.userId,
    this.schoolId,
    this.school,
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
    this.role,
    this.profileStatus,
    this.idType,
    this.studentId,
    this.teacherId,
    this.createDt,
    this.modifyDt,
  });

  @JsonKey(fromJson: _intFromJson)
  final int? id;
  @JsonKey(fromJson: _intFromJson)
  final int? profileId;
  final String? profileCode;
  @JsonKey(fromJson: _intFromJson)
  final int? userId;
  @JsonKey(fromJson: _intFromJson)
  final int? schoolId;
  @JsonKey(fromJson: _schoolFromJson)
  final SchoolDto? school;
  final String? name;
  final String? avatarKey;
  final String? avatarUrl;
  final String? dob;
  @JsonKey(fromJson: _intFromJson)
  final int? gradeId;
  @JsonKey(fromJson: _profileGradeFromJson)
  final ProfileGradeDto? grade;
  @JsonKey(fromJson: _intFromJson)
  final int? programId;
  @JsonKey(fromJson: _programFromJson)
  final ProgramDto? program;
  @JsonKey(fromJson: _intFromJson)
  final int? semesterId;
  @JsonKey(fromJson: _semesterFromJson)
  final SemesterDto? semester;
  @JsonKey(fromJson: _boolFromJson)
  final bool isDefault;
  final String? role;
  final String? profileStatus;
  final String? idType;
  final String? studentId;
  final String? teacherId;
  final String? createDt;
  final String? modifyDt;

  factory StudentProfileDto.fromJson(Map<String, dynamic> json) =>
      _$StudentProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StudentProfileDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ProfileGradeDto {
  const ProfileGradeDto({
    this.id,
    this.gradeId,
    this.label,
    this.description,
    this.displayOrder,
    this.imageUrl,
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

  factory ProfileGradeDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileGradeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileGradeDtoToJson(this);
}

List<StudentProfileDto> _profilesFromJson(Object? value) {
  if (value is List) {
    return value
        .map((item) => _objectFromJson(item, StudentProfileDto.fromJson))
        .whereType<StudentProfileDto>()
        .toList();
  }

  final profile = _objectFromJson(value, StudentProfileDto.fromJson);
  return profile == null
      ? const <StudentProfileDto>[]
      : <StudentProfileDto>[profile];
}

StudentProfileDto? _studentProfileFromJson(Object? value) {
  return _objectFromJson(value, StudentProfileDto.fromJson);
}

SchoolDto? _schoolFromJson(Object? value) {
  return _objectFromJson(value, SchoolDto.fromJson);
}

ProfileGradeDto? _profileGradeFromJson(Object? value) {
  return _objectFromJson(value, ProfileGradeDto.fromJson);
}

ProgramDto? _programFromJson(Object? value) {
  return _objectFromJson(value, ProgramDto.fromJson);
}

SemesterDto? _semesterFromJson(Object? value) {
  return _objectFromJson(value, SemesterDto.fromJson);
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

bool _boolFromJson(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}
