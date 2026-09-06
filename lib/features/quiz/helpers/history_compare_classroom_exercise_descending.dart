import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/quiz/helpers/history_date_value.dart';
import 'package:numi/features/quiz/helpers/history_classroom_exercise_date_text.dart';

int historyCompareClassroomExerciseDescending(
  ClassroomExercise first,
  ClassroomExercise second,
) {
  final firstDate = historyDateValue(historyClassroomExerciseDateText(first));
  final secondDate = historyDateValue(historyClassroomExerciseDateText(second));
  return secondDate.compareTo(firstDate);
}
