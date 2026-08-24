import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';
import 'package:numi/features/quiz/helpers/history_date_value.dart';
import 'package:numi/features/quiz/helpers/history_homework_date_text.dart';

int historyCompareHomeworkDescending(
  ClassroomExercise first,
  ClassroomExercise second,
) {
  final firstDate = historyDateValue(historyHomeworkDateText(first));
  final secondDate = historyDateValue(historyHomeworkDateText(second));
  return secondDate.compareTo(firstDate);
}
