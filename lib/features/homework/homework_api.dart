import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/core/network/network_client.dart';

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
    String? submissionStatus,
    String? purpose,
  });

  Future<ClassroomExercise?> createExercise({
    required int profileId,
    required int classroomId,
    required int programId,
    required String title,
    required String description,
    required int numQuestions,
    required String chapterName,
    required String lessonName,
    required String visibility,
    required String startDate,
    required String endDate,
    String purpose = classroomExercisePurposeHomework,
  });

  Future<ClassroomExercise?> getExerciseDetail({
    required int exerciseId,
    required int profileId,
  });

  Future<ClassroomExercise?> updateExerciseVisibility({
    required int profileId,
    required int classroomExerciseId,
    required String visibility,
    String purpose = classroomExercisePurposeHomework,
  });

  Future<ClassroomExerciseSubmissionResponse> submitExercise({
    required int profileId,
    required int classroomExerciseId,
    required List<SubmitClassroomExerciseAnswer> answers,
  });
}

class ClassroomExerciseApi implements ClassroomExerciseService {
  ClassroomExerciseApi({String? baseUrl, NetworkApi? networkApi})
    : _networkApi =
          networkApi ??
          (baseUrl == null ? NetworkApi.shared : NetworkApi(baseUrl: baseUrl));

  final NetworkApi _networkApi;

  @override
  Future<List<ClassroomExercise>> listExercises({
    required int classroomId,
    required int profileId,
    String? search,
    String? visibility,
    String? submissionStatus,
    String? purpose,
  }) async {
    try {
      final response = await _networkApi.listClassroomExercises(
        ClassroomExerciseListRequest(
          classroomId: classroomId,
          profileId: profileId,
          search: search?.trim().isEmpty == true ? null : search?.trim(),
          visibility: visibility?.trim().isEmpty == true
              ? null
              : visibility?.trim(),
          submissionStatus: submissionStatus?.trim().isEmpty == true
              ? null
              : submissionStatus?.trim(),
          purpose: purpose?.trim().isEmpty == true ? null : purpose?.trim(),
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
    required String description,
    required int numQuestions,
    required String chapterName,
    required String lessonName,
    required String visibility,
    required String startDate,
    required String endDate,
    String purpose = classroomExercisePurposeHomework,
  }) async {
    try {
      final response = await _networkApi.createClassroomExercise(
        CreateClassroomExerciseRequest(
          profileId: profileId,
          classroomId: classroomId,
          programId: programId,
          title: title,
          description: description,
          numQuestions: numQuestions,
          chapterName: chapterName,
          lessonName: lessonName,
          visibility: visibility,
          startDate: startDate,
          endDate: endDate,
          purpose: purpose,
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
      final exercise = response.exercise;
      if (exercise == null) {
        throw const ClassroomExerciseException('');
      }
      return exercise;
    } on NetworkException catch (error) {
      throw ClassroomExerciseException(error.message, status: error.status);
    }
  }

  @override
  Future<ClassroomExercise?> updateExerciseVisibility({
    required int profileId,
    required int classroomExerciseId,
    required String visibility,
    String purpose = classroomExercisePurposeHomework,
  }) async {
    try {
      final response = await _networkApi.updateClassroomExercise(
        UpdateClassroomExerciseRequest(
          profileId: profileId,
          classroomExerciseId: classroomExerciseId,
          visibility: visibility,
          purpose: purpose,
        ),
      );
      return response.exercise;
    } on NetworkException catch (error) {
      throw ClassroomExerciseException(error.message, status: error.status);
    }
  }

  @override
  Future<ClassroomExerciseSubmissionResponse> submitExercise({
    required int profileId,
    required int classroomExerciseId,
    required List<SubmitClassroomExerciseAnswer> answers,
  }) async {
    try {
      return await _networkApi.submitClassroomExercise(
        SubmitClassroomExerciseRequest(
          profileId: profileId,
          classroomExerciseId: classroomExerciseId,
          answers: answers,
        ),
      );
    } on NetworkException catch (error) {
      throw ClassroomExerciseException(error.message, status: error.status);
    }
  }
}
