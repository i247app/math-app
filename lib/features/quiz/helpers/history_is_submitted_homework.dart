import 'package:numi/core/network/classroom_exercise_models.dart';

bool historyIsSubmittedHomework(ClassroomExercise exercise) {
  final purpose = exercise.purpose?.trim().toUpperCase();
  final isHomework =
      purpose == null ||
      purpose.isEmpty ||
      purpose == classroomExercisePurposeHomework;
  return isHomework &&
      exercise.submissionStatus?.trim().toUpperCase() == 'SUBMITTED';
}
