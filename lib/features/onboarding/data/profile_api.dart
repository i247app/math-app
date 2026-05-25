import '../../../core/config/api_config.dart';
import '../../../core/network/network_client.dart';
import '../../../core/network/profile_models.dart';

class ProfileException implements Exception {
  const ProfileException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class ProfileService {
  Future<List<StudentProfile>> listProfiles({required String userId});

  Future<List<ProfileProgram>> listPrograms({required String userId});

  Future<List<ProfileSemester>> listSemesters({required String userId});

  Future<StudentProfile?> createProfile({
    required String userId,
    required String name,
    required String gradeId,
    required String programId,
    required String semesterId,
    String? avatarPath,
    String? dob,
  });
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
  Future<List<ProfileProgram>> listPrograms({required String userId}) async {
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
  Future<List<ProfileSemester>> listSemesters({required String userId}) async {
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
    required String name,
    required String gradeId,
    required String programId,
    required String semesterId,
    String? avatarPath,
    String? dob,
  }) async {
    try {
      final response = await _networkApi.createProfile(
        CreateProfileRequest(
          userId: userId,
          name: name,
          gradeId: gradeId,
          programId: programId,
          semesterId: semesterId,
          dob: dob,
        ),
        avatarPath: avatarPath,
      );
      return response.profile;
    } on NetworkException catch (error) {
      throw ProfileException(error.message, status: error.status);
    }
  }
}
