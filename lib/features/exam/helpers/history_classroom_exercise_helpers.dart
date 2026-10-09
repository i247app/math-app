import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/exam/helpers/history_exam_helpers.dart';

String historyClassroomExerciseDateText(ClassroomExercise exercise) {
  final values = <String?>[
    exercise.modifyDt,
    exercise.createDt,
    exercise.endDate,
    exercise.startDate,
  ];
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return '';
}

int historyCompareClassroomExerciseDescending(
  ClassroomExercise first,
  ClassroomExercise second,
) {
  final firstDate = historyDateValue(historyClassroomExerciseDateText(first));
  final secondDate = historyDateValue(historyClassroomExerciseDateText(second));
  return secondDate.compareTo(firstDate);
}

bool historyIsSubmittedClassroomExercise(ClassroomExercise exercise) {
  final purpose = exercise.purpose?.trim().toUpperCase();
  final isClassroomExercise =
      purpose == null ||
      purpose.isEmpty ||
      purpose == classroomExercisePurposeHomework;
  return isClassroomExercise &&
      exercise.submissionStatus?.trim().toUpperCase() == 'SUBMITTED';
}
