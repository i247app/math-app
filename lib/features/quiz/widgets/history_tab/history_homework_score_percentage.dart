part of '../../history_tab.dart';

int? _historyHomeworkScorePercentage(ClassroomExercise exercise) {
  final metadata = exercise.metadata;
  if (metadata == null) {
    return null;
  }

  final percentage = _historyMetadataInt(metadata, const [
    'score_percentage',
    'score',
    'percentage',
  ]);
  if (percentage != null) {
    return percentage.clamp(0, 100);
  }

  final correct = _historyMetadataInt(metadata, const [
    'correct_number',
    'correct_count',
    'correct_answers',
  ]);
  final total = _historyMetadataInt(metadata, const [
    'total_questions',
    'question_count',
    'total',
  ]);
  if (correct != null && total != null && total > 0) {
    return (correct / total * 100).round().clamp(0, 100);
  }
  return null;
}
