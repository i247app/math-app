import 'package:numi/features/homework/domain/models/classroom_exercise.dart';
import 'package:numi/features/quiz/application/read_models/history_date_value.dart';
import 'package:numi/features/quiz/application/read_models/history_homework_date_text.dart';

int historyCompareHomeworkDescending(
  ClassroomExercise first,
  ClassroomExercise second,
) {
  final firstDate = historyDateValue(historyHomeworkDateText(first));
  final secondDate = historyDateValue(historyHomeworkDateText(second));
  return secondDate.compareTo(firstDate);
}
