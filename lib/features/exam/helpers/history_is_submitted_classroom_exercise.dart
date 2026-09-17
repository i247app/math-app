import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';

bool historyIsSubmittedClassroomExercise(ClassroomExercise exercise) {
  final purpose = exercise.purpose?.trim().toUpperCase();
  final isClassroomExercise =
      purpose == null ||
      purpose.isEmpty ||
      purpose == classroomExercisePurposeHomework;
  return isClassroomExercise &&
      exercise.submissionStatus?.trim().toUpperCase() == 'SUBMITTED';
}
