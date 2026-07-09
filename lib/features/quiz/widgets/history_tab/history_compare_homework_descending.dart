import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_date_value.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_homework_date_text.dart';

int historyCompareHomeworkDescending(
  ClassroomExercise first,
  ClassroomExercise second,
) {
  final firstDate = historyDateValue(historyHomeworkDateText(first));
  final secondDate = historyDateValue(historyHomeworkDateText(second));
  return secondDate.compareTo(firstDate);
}
