part of '../../home_screen.dart';

extension _ParentHomeChildDashboardView on _ParentHomeContentState {
  Widget _buildChildDashboard() {
    final parent = _homeLayout?.parent;
    final padding = EdgeInsets.fromLTRB(
      14 * widget.args.scale,
      widget.args.headerHeight + 10 * widget.args.scale,
      14 * widget.args.scale,
      widget.args.bottomPadding + 18 * widget.args.scale,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8FCFC),
            Color(0xFFEFF8F7),
          ],
          stops: [0, 0.42, 1],
        ),
      ),
      child: RefreshIndicator(
        color: const Color(0xFF159A86),
        onRefresh: _loadHome,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: padding,
          child: _isLoading && !_hasLoadedHome
              ? const _ParentChildDashboardLoading()
              : _ParentModeThreeContent(
                  summaries: _childSummaries,
                  pendingExercises: parent?.pendingExercises ??
                      const <HomeLayoutPendingExercise>[],
                  completions: parent?.recentCompletions ??
                      const <HomeLayoutRecentCompletion>[],
                  entranceBuilder: _modeThreeFadeIn,
                  onPendingTap: _openPendingExercise,
                  onCompletionTap: _openCompletionResult,
                  onViewTasks: widget.args.onOpenClassroomTab,
                  onViewResults: widget.args.onOpenClassroomTab,
                  onViewMessages: widget.args.onOpenClassroomTab,
                  isRefreshing: _isLoading && _hasLoadedHome,
                  errorMessage: _errorMessage,
                  onRetry: _loadHome,
                ),
        ),
      ),
    );
  }
}
