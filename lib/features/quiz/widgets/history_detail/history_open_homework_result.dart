part of '../../history_tab.dart';

void _historyOpenHomeworkResult(
  BuildContext context,
  ClassroomExercise exercise, {
  required int? profileId,
  required ClassroomExerciseService exerciseService,
}) {
  final exerciseId = exercise.stableId;
  if (exerciseId == null || profileId == null) {
    context.showErrorDialog(
      context.readText(AppKeys.studentHomeworkLoadFailed),
    );
    return;
  }

  HapticFeedback.selectionClick();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => HomeworkReviewScreen(
        exerciseId: exerciseId,
        profileId: profileId,
        exerciseService: exerciseService,
        initialExercise: exercise,
      ),
    ),
  );
}
