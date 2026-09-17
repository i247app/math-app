import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';

abstract interface class ClassroomExerciseService {
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
