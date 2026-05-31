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
  Future<List<ClassroomModel>> listClassrooms({required int profileId});

  Future<ClassroomModel?> createClassroom({
    required int profileId,
    required String name,
    required List<int> programIds,
    required int gradeId,
    required int schoolId,
    int maxMembers = 50,
    String? description,
    String? filePath,
  });

  Future<ClassroomModel?> getClassroomDetail({
    required int classroomId,
    required int profileId,
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
    required int profileId,
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
    required int profileId,
    required String name,
    required List<int> programIds,
    required int gradeId,
    required int schoolId,
    int maxMembers = 50,
    String? description,
    String? filePath,
  }) async {
    try {
      final response = await _networkApi.createClassroom(
        CreateClassroomRequest(
          profileId: profileId,
          name: name,
          programIds: programIds,
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
    required int classroomId,
    required int profileId,
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
