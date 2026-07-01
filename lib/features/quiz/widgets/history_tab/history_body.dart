part of '../../history_tab.dart';

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({
    required this.isLoading,
    required this.errorMessage,
    required this.selectedFilter,
    required this.selectedItemsCount,
    required this.quizzes,
    required this.homeworkExercises,
    required this.onRetry,
    required this.scale,
  });

  final bool isLoading;
  final String? errorMessage;
  final _HistoryFilter selectedFilter;
  final int selectedItemsCount;
  final List<GeneratedQuiz> quizzes;
  final List<ClassroomExercise> homeworkExercises;
  final VoidCallback onRetry;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (isLoading && selectedItemsCount == 0) {
      return _HistoryLoadingState(scale: scale);
    }

    if (errorMessage != null && selectedItemsCount == 0) {
      return _HistoryMessageState(
        icon: Icons.cloud_off_rounded,
        title: context.getText(AppKeys.historyLoadErrorTitle),
        subtitle: errorMessage!,
        actionLabel: context.getText(AppKeys.retry).toUpperCase(),
        onAction: onRetry,
        scale: scale,
      );
    }

    if (selectedItemsCount == 0) {
      return _HistoryMessageState(
        icon: Icons.history_toggle_off_rounded,
        title: context.getText(AppKeys.noHistoryTitle),
        subtitle: context.getText(AppKeys.noHistoryMessage),
        scale: scale,
      );
    }

    return switch (selectedFilter) {
      _HistoryFilter.homework => Column(
        children: [
          for (final exercise in homeworkExercises) ...[
            _HistoryHomeworkCard(
              exercise: exercise,
              scale: scale,
              onTap: () => _historyOpenHomeworkResult(context, exercise),
            ),
            SizedBox(height: 14 * scale),
          ],
        ],
      ),
      _HistoryFilter.assessment => Column(
        children: [
          for (final quiz in quizzes) ...[
            _HistoryQuizCard(
              quiz: quiz,
              scale: scale,
              onTap: () => _historyOpenQuizReview(context, quiz),
            ),
            SizedBox(height: 14 * scale),
          ],
        ],
      ),
    };
  }
}
