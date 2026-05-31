import '../../../core/config/api_config.dart';
import '../../../core/network/network_client.dart';
import '../../../core/network/profile_models.dart';
import '../../../core/network/program_models.dart';
import '../../../core/network/semester_models.dart';

class ProfileException implements Exception {
  const ProfileException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class ProfileService {
  Future<List<StudentProfile>> listProfiles({required String userId});

  Future<List<ProgramModel>> listPrograms({required String userId});

  Future<List<SemesterModel>> listSemesters({required String userId});

  Future<StudentProfile?> createProfile({
    required String userId,
    required String schoolId,
    required String name,
    String? gradeId,
    String? programId,
    String? semesterId,
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
    required String profileId,
    String? schoolId,
    String? name,
    String? gradeId,
    String? programId,
    String? semesterId,
    bool? isDefault,
    String? role,
    String? avatarPath,
    String? avatarKey,
    String? dob,
    String? idType,
    String? studentId,
    String? teacherId,
  });

  Future<void> forceDeleteProfile({required String profileId});
}

class ProfileApi implements ProfileService {
  ProfileApi({
    String? baseUrl,
    NetworkApi? networkApi,
  }) : _networkApi =
            networkApi ?? NetworkApi(baseUrl: baseUrl ?? ApiConfig.baseUrl);

  final NetworkApi _networkApi;

  @override
  Future<List<StudentProfile>> listProfiles({required String userId}) async {
    try {
      final response = await _networkApi.listProfiles(
        ProfileListRequest(userId: userId),
      );
      return response.profiles;
    } on NetworkException catch (error) {
      throw ProfileException(error.message, status: error.status);
    }
  }

  @override
  Future<List<ProgramModel>> listPrograms({required String userId}) async {
    try {
      final response = await _networkApi.listPrograms(
        ProgramListRequest(userId: userId),
      );
      return response.programs;
    } on NetworkException catch (error) {
      throw ProfileException(error.message, status: error.status);
    }
  }

  @override
  Future<List<SemesterModel>> listSemesters({required String userId}) async {
    try {
      final response = await _networkApi.listSemesters(
        SemesterListRequest(userId: userId),
      );
      return response.semesters;
    } on NetworkException catch (error) {
      throw ProfileException(error.message, status: error.status);
    }
  }

  @override
  Future<StudentProfile?> createProfile({
    required String userId,
    required String schoolId,
    required String name,
    String? gradeId,
    String? programId,
    String? semesterId,
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
      final response = await _networkApi.createProfile(
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
    required String profileId,
    String? schoolId,
    String? name,
    String? gradeId,
    String? programId,
    String? semesterId,
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
      final response = await _networkApi.updateProfile(
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
  Future<void> forceDeleteProfile({required String profileId}) async {
    try {
      await _networkApi.forceDeleteProfile(
        DeleteProfileRequest(profileId: profileId),
      );
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
}
