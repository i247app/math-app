import '../../../core/config/api_config.dart';
import '../../../core/network/classroom_models.dart';
import '../../../core/network/network_client.dart';

class ClassroomException implements Exception {
  const ClassroomException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class ClassroomService {
  Future<List<ClassroomModel>> listClassrooms({required String profileId});

  Future<ClassroomModel?> createClassroom({
    required String profileId,
    required String name,
    required String programId,
    required String gradeId,
    required String schoolId,
    int maxMembers = 50,
    String? description,
    String? filePath,
  });

  Future<ClassroomModel?> getClassroomDetail({
    required String classroomId,
    required String profileId,
  });
}

class ClassroomApi implements ClassroomService {
  ClassroomApi({
    String? baseUrl,
    NetworkApi? networkApi,
  }) : _networkApi =
            networkApi ?? NetworkApi(baseUrl: baseUrl ?? ApiConfig.baseUrl);

  final NetworkApi _networkApi;

  @override
  Future<List<ClassroomModel>> listClassrooms({
    required String profileId,
  }) async {
    try {
      final response = await _networkApi.listClassrooms(
        ClassroomListRequest(profileId: profileId),
      );
      return response.classrooms;
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<ClassroomModel?> createClassroom({
    required String profileId,
    required String name,
    required String programId,
    required String gradeId,
    required String schoolId,
    int maxMembers = 50,
    String? description,
    String? filePath,
  }) async {
    try {
      final response = await _networkApi.createClassroom(
        CreateClassroomRequest(
          profileId: profileId,
          name: name,
          programId: programId,
          gradeId: gradeId,
          schoolId: schoolId,
          maxMembers: maxMembers,
          description: description,
        ),
        filePath: filePath,
      );
      return response.classroom;
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }

  @override
  Future<ClassroomModel?> getClassroomDetail({
    required String classroomId,
    required String profileId,
  }) async {
    try {
      final response = await _networkApi.getClassroomDetail(
        classroomId: classroomId,
        profileId: profileId,
      );
      return response.classroom;
    } on NetworkException catch (error) {
      throw ClassroomException(error.message, status: error.status);
    }
  }
}
