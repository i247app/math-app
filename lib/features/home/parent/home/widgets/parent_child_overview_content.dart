part of '../../../home_screen.dart';

class _ParentChildOverviewContent extends StatelessWidget {
  const _ParentChildOverviewContent({
    required this.summaries,
    required this.pendingExercises,
    required this.completions,
    required this.entranceBuilder,
    required this.onCompletionTap,
    required this.onViewTasks,
    required this.onViewResults,
    required this.onViewMessages,
    required this.isRefreshing,
    required this.errorMessage,
    required this.onRetry,
  });

  final List<_ParentChildSummary> summaries;
  final List<HomeLayoutPendingExercise> pendingExercises;
  final List<HomeLayoutRecentCompletion> completions;
  final _ParentHomeEntranceBuilder entranceBuilder;
  final ValueChanged<HomeLayoutRecentCompletion> onCompletionTap;
  final VoidCallback onViewTasks;
  final VoidCallback onViewResults;
  final VoidCallback onViewMessages;
  final bool isRefreshing;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final primarySummary = _parentPrimarySummary(summaries);
    final showGameSuggestions = pendingExercises.isEmpty || completions.isEmpty;
    final visiblePendingExercises =
        pendingExercises.take(2).toList(growable: false);
    final visibleCompletions = completions.take(2).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        entranceBuilder(
          order: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ParentChildClassSummaryCard(summary: primarySummary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (pendingExercises.isNotEmpty) ...[
          entranceBuilder(
            order: 1,
            child: _ParentDashboardSection(
              title: 'Nhiệm vụ',
              onViewAll: pendingExercises.length > 2 ? onViewTasks : null,
              child: Column(
                children: [
                  for (var index = 0;
                      index < visiblePendingExercises.length;
                      index++) ...[
                    _ParentPendingTaskListItem(
                      pending: visiblePendingExercises[index],
                    ),
                    if (index != visiblePendingExercises.length - 1)
                      const Divider(
                        height: 24,
                        indent: 62,
                        color: Color(0xFFE9EEF2),
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (completions.isNotEmpty) ...[
          entranceBuilder(
            order: 2,
            child: _ParentDashboardSection(
              title: context.getText(AppKeys.assessmentResultTitle),
              onViewAll: completions.length > 2 ? onViewResults : null,
              child: Column(
                children: [
                  for (var index = 0;
                      index < visibleCompletions.length;
                      index++) ...[
                    _ParentCompletedTaskListItem(
                      completion: visibleCompletions[index],
                      onTap: () => onCompletionTap(visibleCompletions[index]),
                    ),
                    if (index != visibleCompletions.length - 1)
                      const Divider(
                        height: 24,
                        indent: 62,
                        color: Color(0xFFE9EEF2),
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        entranceBuilder(
          order: 3,
          markOnEnd: !showGameSuggestions,
          child: _ParentDashboardSection(
            title: 'Tin nhắn',
            onViewAll: onViewMessages,
            child: _ParentTeacherMessagesList(summaries: summaries),
          ),
        ),
        if (showGameSuggestions) ...[
          const SizedBox(height: 14),
          entranceBuilder(
            order: 4,
            markOnEnd: true,
            child: const _ParentGameSuggestionsRow(),
          ),
        ],
        if (isRefreshing) ...[
          const SizedBox(height: 8),
          const _ParentHomeRefreshLabel(),
        ],
        if (errorMessage != null) ...[
          const SizedBox(height: 10),
          _ParentHomeErrorCard(message: errorMessage!, onRetry: onRetry),
        ],
      ],
    );
  }
}
