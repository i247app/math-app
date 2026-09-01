part of '../parent_assessment_tab.dart';

extension _ParentAssessmentContentBuilder on _ParentAssessmentTabState {
  List<Widget> _buildAssessmentChildren({
    required List<ParentAssessmentEntry> entries,
    required bool hasNoAssessments,
    required bool shouldShowFullSkeleton,
  }) {
    final colors = context.themeColors;
    final shouldShowProgressChart = _allEntries.length > 1;

    if (shouldShowFullSkeleton) {
      return const [ParentAssessmentFullSkeleton()];
    }

    if (hasNoAssessments) {
      return [
        _initialFadeIn(
          child: ParentAssessmentEmptyPoster(onTap: _openAssessment),
        ),
      ];
    }

    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: ParentAssessmentTabBanner(onTap: _openAssessment),
      ),
      ParentAssessmentSearchField(controller: _searchController),
      if (shouldShowProgressChart) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
          child: Text(
            context.getText(AppKeys.parentLearningProgress),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: FontSize.large,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ),
        ParentAssessmentProgressChart(
          entries: _allEntries.take(5).toList().reversed.toList(),
          onTap: _openLearningProgress,
        ),
      ],
      if (_errorMessage != null && _entries.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _initialFadeIn(
            child: ParentAssessmentStateCard(
              icon: Icons.cloud_off_rounded,
              title: context.getText(AppKeys.historyLoadErrorTitle),
              message: _errorMessage!,
              onTap: _loadAssessments,
            ),
          ),
        )
      else if (entries.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _initialFadeIn(
            child: Column(
              spacing: 14,
              children: [
                ParentAssessmentStateCard(
                  icon: Icons.assignment_turned_in_outlined,
                  title: context.getText(AppKeys.noHistoryTitle),
                  message: context.getText(AppKeys.noHistoryMessage),
                  onTap: _loadAssessments,
                ),
                ?_buildPagination(),
              ],
            ),
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _initialFadeIn(
            child: Column(
              spacing: 14,
              children: [
                ...entries.map(
                  (entry) => AssessmentResultListItemCard(
                    quiz: entry.quiz,
                    onTap: () => _openQuizReview(entry.quiz),
                  ),
                ),
                ?_buildPagination(topPadding: 6),
              ],
            ),
          ),
        ),
    ];
  }

  Widget _initialFadeIn({required Widget child}) {
    if (_hasPlayedInitialEntrance) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: homeFadeInDuration,
      curve: Curves.easeOut,
      onEnd: _markInitialEntrancePlayed,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 4 * (1 - value)),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }

  void _markInitialEntrancePlayed() {
    if (!mounted || _hasPlayedInitialEntrance) {
      return;
    }
    _updateState(() => _hasPlayedInitialEntrance = true);
  }
}
