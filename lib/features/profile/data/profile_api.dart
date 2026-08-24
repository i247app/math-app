import 'package:dio/dio.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/profile/data/dto/program_models.dart';
import 'package:numi/features/profile/data/dto/semester_models.dart';
import 'package:numi/features/profile/data/profile_exception.dart';

abstract class ProfileService {
  Future<List<StudentProfile>> listProfiles({required int userId});

  Future<List<StudentProfile>> searchProfiles({required String search});

  Future<List<ProgramModel>> listPrograms({required int userId});

  Future<List<SemesterModel>> listSemesters({required int userId});

  Future<StudentProfile?> createProfile({
    required int userId,
    required int schoolId,
    required String name,
    int? gradeId,
    int? programId,
    int? semesterId,
    bool isDefault = false,
    String role = 'STUDENT',
    String? avatarPath,
    String? avatarKey,
    String? dob,
    String? idType,
    String? studentId,
    String? teacherId,
  });

  Future<StudentProfile?> updateProfile({
    required int profileId,
    int? schoolId,
    String? name,
    int? gradeId,
    int? programId,
    int? semesterId,
    bool? isDefault,
    String? role,
    String? avatarPath,
    String? avatarKey,
    String? dob,
    String? idType,
    String? studentId,
    String? teacherId,
  });

  Future<void> forceDeleteProfile({required int profileId});
}

class ProfileApi implements ProfileService {
  ProfileApi({String? baseUrl, NetworkClient? networkClient})
    : _networkClient =
          networkClient ??
          (baseUrl == null
              ? NetworkClient.shared
              : NetworkClient(baseUrl: baseUrl));

  final NetworkClient _networkClient;

  @override
  Future<List<StudentProfile>> listProfiles({required int userId}) async {
    try {
      final response = await _listProfiles(ProfileListRequest(userId: userId));
      return response.profiles;
    } on NetworkException catch (error) {
      throw ProfileException(error.message, status: error.status);
    }
  }

  @override
  Future<List<StudentProfile>> searchProfiles({required String search}) async {
    try {
      final response = await _listProfiles(ProfileListRequest(search: search));
      return response.profiles;
    } on NetworkException catch (error) {
      throw ProfileException(error.message, status: error.status);
    }
  }

  @override
  Future<List<ProgramModel>> listPrograms({required int userId}) async {
    try {
      final response = await _listPrograms(ProgramListRequest(userId: userId));
      return response.programs;
    } on NetworkException catch (error) {
      throw ProfileException(error.message, status: error.status);
    }
  }

  @override
  Future<List<SemesterModel>> listSemesters({required int userId}) async {
    try {
      final response = await _listSemesters(
        SemesterListRequest(userId: userId),
      );
      return response.semesters;
    } on NetworkException catch (error) {
      throw ProfileException(error.message, status: error.status);
    }
  }

  @override
  Future<StudentProfile?> createProfile({
    required int userId,
    required int schoolId,
    required String name,
    int? gradeId,
    int? programId,
    int? semesterId,
    bool isDefault = false,
    String role = 'STUDENT',
    String? avatarPath,
    String? avatarKey,
    String? dob,
    String? idType,
    String? studentId,
    String? teacherId,
  }) async {
    try {
      final response = await _createProfile(
        CreateProfileRequest(
          userId: userId,
          schoolId: schoolId,
          name: name,
          gradeId: gradeId,
          programId: programId,
          semesterId: semesterId,
          isDefault: isDefault,
          role: _normalizedRole(role),
          dob: dob,
          avatarKey: _emptyToNull(avatarKey),
          idType: _emptyToNull(idType)?.toUpperCase(),
          studentId: _emptyToNull(studentId),
          teacherId: _emptyToNull(teacherId),
        ),
        avatarPath: avatarPath,
      );
      return response.profile;
    } on NetworkException catch (error) {
      throw ProfileException(error.message, status: error.status);
    }
  }

  @override
  Future<StudentProfile?> updateProfile({
    required int profileId,
    int? schoolId,
    String? name,
    int? gradeId,
    int? programId,
    int? semesterId,
    bool? isDefault,
    String? role,
    String? avatarPath,
    String? avatarKey,
    String? dob,
    String? idType,
    String? studentId,
    String? teacherId,
  }) async {
    try {
      final response = await _updateProfile(
        UpdateProfileRequest(
          profileId: profileId,
          schoolId: schoolId,
          name: name,
          gradeId: gradeId,
          programId: programId,
          semesterId: semesterId,
          isDefault: isDefault,
          role: role == null ? null : _normalizedRole(role),
          dob: dob,
          avatarKey: _emptyToNull(avatarKey),
          idType: _emptyToNull(idType)?.toUpperCase(),
          studentId: _emptyToNull(studentId),
          teacherId: _emptyToNull(teacherId),
        ),
        avatarPath: avatarPath,
      );
      return response.profile;
    } on NetworkException catch (error) {
      throw ProfileException(error.message, status: error.status);
    }
  }

  @override
  Future<void> forceDeleteProfile({required int profileId}) async {
    try {
      await _forceDeleteProfile(DeleteProfileRequest(profileId: profileId));
    } on NetworkException catch (error) {
      throw ProfileException(error.message, status: error.status);
    }
  }

  static String _normalizedRole(String value) {
    final role = value.trim().toUpperCase();
    return switch (role) {
      'TEACHER' || 'PARENT' || 'STUDENT' => role,
      _ => 'STUDENT',
    };
  }

  static String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  Future<ProfileListResponse> _listProfiles(ProfileListRequest request) {
    return _postResponse(
      '/profiles/list',
      request.toJson(),
      ProfileListResponse.fromJson,
    );
  }

  Future<ProgramListResponse> _listPrograms(ProgramListRequest request) {
    return _postResponse(
      '/programs/list',
      request.toJson(),
      ProgramListResponse.fromJson,
    );
  }

  Future<SemesterListResponse> _listSemesters(SemesterListRequest request) {
    return _postResponse(
      '/semesters/list',
      request.toJson(),
      SemesterListResponse.fromJson,
    );
  }

  Future<CreateProfileResponse> _createProfile(
    CreateProfileRequest request, {
    String? avatarPath,
  }) async {
    final formData = FormData.fromMap({
      'user_id': request.userId,
      'school_id': request.schoolId,
      'name': request.name,
      if (request.dob?.isNotEmpty == true) 'dob': request.dob,
      if (request.gradeId != null) 'grade_id': request.gradeId,
      if (request.programId != null) 'program_id': request.programId,
      if (request.semesterId != null) 'semester_id': request.semesterId,
      'is_default': request.isDefault,
      'role': request.role,
      if (request.avatarKey?.isNotEmpty == true)
        'avatar_key': request.avatarKey,
      if (request.idType?.isNotEmpty == true) 'id_type': request.idType,
      if (request.studentId?.isNotEmpty == true)
        'student_id': request.studentId,
      if (request.teacherId?.isNotEmpty == true)
        'teacher_id': request.teacherId,
      if (avatarPath?.isNotEmpty == true)
        'avatar': await MultipartFile.fromFile(avatarPath!),
    });
    final json = await _networkClient.postMultipart(
      '/profiles/create',
      formData,
    );
    NetworkClient.throwForApiStatus(json);
    return CreateProfileResponse.fromJson(json);
  }

  Future<UpdateProfileResponse> _updateProfile(
    UpdateProfileRequest request, {
    String? avatarPath,
  }) async {
    final formData = FormData.fromMap({
      'profile_id': request.profileId,
      if (request.schoolId != null) 'school_id': request.schoolId,
      if (request.name?.isNotEmpty == true) 'name': request.name,
      if (request.dob?.isNotEmpty == true) 'dob': request.dob,
      if (request.gradeId != null) 'grade_id': request.gradeId,
      if (request.programId != null) 'program_id': request.programId,
      if (request.semesterId != null) 'semester_id': request.semesterId,
      if (request.isDefault != null) 'is_default': request.isDefault,
      if (request.role?.isNotEmpty == true) 'role': request.role,
      if (request.avatarKey?.isNotEmpty == true)
        'avatar_key': request.avatarKey,
      if (request.idType?.isNotEmpty == true) 'id_type': request.idType,
      if (request.studentId?.isNotEmpty == true)
        'student_id': request.studentId,
      if (request.teacherId?.isNotEmpty == true)
        'teacher_id': request.teacherId,
      if (avatarPath?.isNotEmpty == true)
        'avatar': await MultipartFile.fromFile(avatarPath!),
    });
    final json = await _networkClient.postMultipart(
      '/profiles/update',
      formData,
    );
    NetworkClient.throwForApiStatus(json);
    return UpdateProfileResponse.fromJson(json);
  }

  Future<DeleteProfileResponse> _forceDeleteProfile(
    DeleteProfileRequest request,
  ) {
    return _postResponse(
      '/profiles/force-delete',
      request.toJson(),
      DeleteProfileResponse.fromJson,
    );
  }

  Future<T> _postResponse<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final json = await _networkClient.postJson(path, body);
    NetworkClient.throwForApiStatus(json);
    return fromJson(json);
  }
}
