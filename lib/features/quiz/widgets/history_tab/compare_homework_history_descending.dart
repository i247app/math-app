part of '../../history_tab.dart';

int _compareHomeworkHistoryDescending(
  ClassroomExercise first,
  ClassroomExercise second,
) {
  final firstDate = _historyDateValue(_historyHomeworkDateText(first));
  final secondDate = _historyDateValue(_historyHomeworkDateText(second));
  return secondDate.compareTo(firstDate);
}
