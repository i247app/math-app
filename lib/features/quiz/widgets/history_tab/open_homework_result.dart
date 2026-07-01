part of '../../history_tab.dart';

void _openHomeworkResult(BuildContext context, ClassroomExercise exercise) {
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
