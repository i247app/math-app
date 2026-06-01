import '../../../core/config/api_config.dart';
import '../../../core/network/classroom_exercise_models.dart';
import '../../../core/network/network_client.dart';

class ClassroomExerciseException implements Exception {
  const ClassroomExerciseException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

abstract class ClassroomExerciseService {
  Future<List<ClassroomExercise>> listExercises({
    required int classroomId,
    required int profileId,
    String? search,
    String? visibility,
  });

  Future<ClassroomExercise?> createExercise({
    required int profileId,
    required int classroomId,
    required int programId,
    required String title,
    required int numQuestions,
    required String chapterName,
    required String lessonName,
    required String visibility,
    required String startDate,
    required String endDate,
  });

  Future<ClassroomExercise?> getExerciseDetail({
    required int exerciseId,
    required int profileId,
  });

  Future<ClassroomExercise?> updateExerciseVisibility({
    required int profileId,
    required int classroomExerciseId,
    required String visibility,
  });
}

class ClassroomExerciseApi implements ClassroomExerciseService {
  ClassroomExerciseApi({
    String? baseUrl,
    NetworkApi? networkApi,
  }) : _networkApi =
            networkApi ?? NetworkApi(baseUrl: baseUrl ?? ApiConfig.baseUrl);

  final NetworkApi _networkApi;

  @override
  Future<List<ClassroomExercise>> listExercises({
    required int classroomId,
    required int profileId,
    String? search,
    String? visibility,
  }) async {
    try {
      final response = await _networkApi.listClassroomExercises(
        ClassroomExerciseListRequest(
          classroomId: classroomId,
          profileId: profileId,
          search: search?.trim().isEmpty == true ? null : search?.trim(),
          visibility:
              visibility?.trim().isEmpty == true ? null : visibility?.trim(),
        ),
      );
      return response.exercises;
    } on NetworkException catch (error) {
      throw ClassroomExerciseException(error.message, status: error.status);
    }
  }

  @override
  Future<ClassroomExercise?> createExercise({
    required int profileId,
    required int classroomId,
    required int programId,
    required String title,
    required int numQuestions,
    required String chapterName,
    required String lessonName,
    required String visibility,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _networkApi.createClassroomExercise(
        CreateClassroomExerciseRequest(
          profileId: profileId,
          classroomId: classroomId,
          programId: programId,
          title: title,
          numQuestions: numQuestions,
          chapterName: chapterName,
          lessonName: lessonName,
          visibility: visibility,
          startDate: startDate,
          endDate: endDate,
        ),
      );
      return response.exercise;
    } on NetworkException catch (error) {
      throw ClassroomExerciseException(error.message, status: error.status);
    }
  }

  @override
  Future<ClassroomExercise?> getExerciseDetail({
    required int exerciseId,
    required int profileId,
  }) async {
    try {
      final response = await _networkApi.getClassroomExerciseDetail(
        exerciseId: exerciseId,
        profileId: profileId,
      );
      return response.exercise;
    } on NetworkException catch (error) {
      throw ClassroomExerciseException(error.message, status: error.status);
    }
  }

  @override
  Future<ClassroomExercise?> updateExerciseVisibility({
    required int profileId,
    required int classroomExerciseId,
    required String visibility,
  }) async {
    try {
      final response = await _networkApi.updateClassroomExercise(
        UpdateClassroomExerciseRequest(
          profileId: profileId,
          classroomExerciseId: classroomExerciseId,
          visibility: visibility,
        ),
      );
      return response.exercise;
    } on NetworkException catch (error) {
      throw ClassroomExerciseException(error.message, status: error.status);
    }
  }
}
