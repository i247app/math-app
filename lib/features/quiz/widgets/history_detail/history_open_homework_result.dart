part of '../../history_tab.dart';

void _historyOpenHomeworkResult(
  BuildContext context,
  ClassroomExercise exercise,
) {
  HapticFeedback.selectionClick();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => StudentHomeworkResultScreen(
        summary: StudentHomeworkResultSummary(
          scoreText: _historyHomeworkScoreText(exercise),
          reviewText: context.getText(AppKeys.defaultAiReview),
        ),
      ),
    ),
  );
}
