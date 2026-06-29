part of '../../../home_screen.dart';

class _ParentRoomDetailScreen extends StatelessWidget {
  const _ParentRoomDetailScreen({
    required this.entry,
    required this.pendingExercises,
    required this.expiredExercises,
    required this.completions,
    required this.exerciseService,
    required this.onRefreshLayout,
  });

  final _ParentRoomEntry entry;
  final List<HomeLayoutPendingExercise> pendingExercises;
  final List<HomeLayoutPendingExercise> expiredExercises;
  final List<HomeLayoutRecentCompletion> completions;
  final ClassroomExerciseService exerciseService;
  final Future<void> Function() onRefreshLayout;

  @override
  Widget build(BuildContext context) {
    final title = _roomClassName(context, entry.classroom);
    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ParentRoomDetailTopBar(
              title: title,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  14,
                  18,
                  14,
                  MediaQuery.paddingOf(context).bottom + 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ParentRoomDetailHero(entry: entry),
                    const SizedBox(height: 18),
                    _ParentRoomDetailShortcuts(
                      pendingCount:
                          pendingExercises.length + expiredExercises.length,
                      completedCount: completions.length,
                    ),
                    const SizedBox(height: 26),
                    _ParentRoomListSection(
                      title: context.formatText(AppKeys.parentTasksCountTitle, {
                        'count':
                            pendingExercises.length + expiredExercises.length,
                      }),
                      onViewAll: () => _parentRoomShowComingSoon(context),
                      child:
                          pendingExercises.isEmpty && expiredExercises.isEmpty
                          ? _ParentEmptyTaskLine(
                              icon: Icons.assignment_turned_in_outlined,
                              text: context.getText(
                                AppKeys.studentNoHomeworkTitle,
                              ),
                            )
                          : Column(
                              children: [
                                for (final pending in pendingExercises) ...[
                                  _ParentPendingTaskListItem(pending: pending),
                                  if (pending != pendingExercises.last ||
                                      expiredExercises.isNotEmpty)
                                    const Divider(
                                      height: 24,
                                      indent: 62,
                                      color: Color(0xFFE9EEF2),
                                    ),
                                ],
                                for (final expired in expiredExercises) ...[
                                  _ParentPendingTaskListItem(
                                    pending: expired,
                                    isExpired: true,
                                    onTap: () =>
                                        _showExpiredExerciseMessage(context),
                                  ),
                                  if (expired != expiredExercises.last)
                                    const Divider(
                                      height: 24,
                                      indent: 62,
                                      color: Color(0xFFE9EEF2),
                                    ),
                                ],
                              ],
                            ),
                    ),
                    const SizedBox(height: 14),
                    _ParentRoomListSection(
                      title: context.getText(AppKeys.assessmentResultTitle),
                      onViewAll: () => _parentRoomShowComingSoon(context),
                      child: completions.isEmpty
                          ? _ParentEmptyTaskLine(
                              icon: Icons.fact_check_outlined,
                              text: context.getText(
                                AppKeys.noCompletedHomeworkTitle,
                              ),
                            )
                          : Column(
                              children: [
                                for (final completion in completions) ...[
                                  _ParentCompletedTaskListItem(
                                    completion: completion,
                                    onTap: () => _openCompletionResult(
                                      context,
                                      completion,
                                    ),
                                  ),
                                  if (completion != completions.last)
                                    const Divider(
                                      height: 24,
                                      indent: 62,
                                      color: Color(0xFFE9EEF2),
                                    ),
                                ],
                              ],
                            ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCompletionResult(
    BuildContext context,
    HomeLayoutRecentCompletion completion,
  ) {
    final quiz = _quizFromRecentCompletion(completion);
    final quizId = quiz.quizId ?? quiz.id;
    if (quizId == null || quizId <= 0) {
      return;
    }
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizReviewScreen(quizId: quizId, initialQuiz: quiz),
      ),
    );
  }
}
