part of '../../history_tab.dart';

String _historyHomeworkScoreText(ClassroomExercise exercise) {
  final scorePercent = _historyHomeworkScorePercentage(exercise);
  if (scorePercent != null) {
    final scoreOutOf10 = (scorePercent / 10).round().clamp(0, 10);
    return '$scoreOutOf10/10';
  }
  return '--/10';
}
