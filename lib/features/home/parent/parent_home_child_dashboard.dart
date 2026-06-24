part of '../home_screen.dart';

extension _ParentHomeChildDashboardView on _ParentHomeContentState {
  Widget _buildChildDashboard() {
    final summaries = _childSummaries;
    final assessments = <_ParentChildAssessment>[
      for (final summary in summaries)
        for (final quiz in summary.assessments)
          _ParentChildAssessment(summary: summary, quiz: quiz),
    ]..sort((a, b) => _quizDate(b.quiz).compareTo(_quizDate(a.quiz)));
    final padding = EdgeInsets.fromLTRB(
      20 * widget.args.scale,
      widget.args.headerHeight + 8 * widget.args.scale,
      20 * widget.args.scale,
      widget.args.bottomPadding,
    );

    return RefreshIndicator(
      color: const Color(0xFF159A86),
      onRefresh: _loadHome,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading && summaries.isEmpty && !_hasLoadedHome)
              const _ParentChildDashboardLoading()
            else
              _modeThreeFadeIn(
                order: 0,
                markOnEnd: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ParentChildrenGrid(summaries: summaries),
                    const SizedBox(height: 14),
                    for (final item in assessments.take(2)) ...[
                      _ParentAssessmentResultCard(
                        quiz: item.quiz,
                        profileName: homeProfileDisplayName(
                          context,
                          item.summary.profile,
                        ),
                        classroomName: _parentClassroomName(
                          context,
                          item.summary,
                        ),
                        onTap: () => _openQuizReview(item.quiz),
                      ),
                      const SizedBox(height: 10),
                    ],
                    _ParentTeacherMessages(
                      summaries: summaries.take(2).toList(),
                    ),
                  ],
                ),
              ),
            if (!_isLoading && _errorMessage != null) ...[
              const SizedBox(height: 10),
              _ParentHomeErrorCard(
                message: _errorMessage!,
                onRetry: _loadHome,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
