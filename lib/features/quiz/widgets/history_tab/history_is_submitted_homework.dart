part of '../../history_tab.dart';

bool _historyIsSubmittedHomework(ClassroomExercise exercise) {
  final purpose = exercise.purpose?.trim().toUpperCase();
  final isHomework =
      purpose == null ||
      purpose.isEmpty ||
      purpose == classroomExercisePurposeHomework;
  return isHomework &&
      exercise.submissionStatus?.trim().toUpperCase() == 'SUBMITTED';
}
