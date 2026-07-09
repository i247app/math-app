import 'package:flutter/material.dart';
import 'package:numi/features/home/home_api.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_child_dashboard_loading.dart';
import 'package:numi/features/home/parent/home/parent_home_tab.dart';
import 'package:numi/features/home/parent/home/widgets/parent_child_overview_content.dart';

extension ParentHomeChildDashboardView on ParentHomeContentState {
  Widget buildChildDashboard() {
    final parent = homeLayout?.parent;
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
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FCFC), Color(0xFFEFF8F7)],
          stops: [0, 0.42, 1],
        ),
      ),
      child: RefreshIndicator(
        color: const Color(0xFF159A86),
        onRefresh: loadHome,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: padding,
          child: isLoading && !hasLoadedHome
              ? const ParentChildDashboardLoading()
              : ParentChildOverviewContent(
                  summaries: childSummaries,
                  pendingExercises:
                      parent?.pendingExercises ??
                      const <HomeLayoutPendingExercise>[],
                  completions:
                      parent?.recentCompletions ??
                      const <HomeLayoutRecentCompletion>[],
                  entranceBuilder: childOverviewFadeIn,
                  onCompletionTap: openCompletionResult,
                  onViewTasks: widget.args.onOpenClassroomTab,
                  onViewResults: widget.args.onOpenClassroomTab,
                  onViewMessages: widget.args.onOpenClassroomTab,
                  isRefreshing: isLoading && hasLoadedHome,
                  errorMessage: errorMessage,
                  onRetry: loadHome,
                ),
        ),
      ),
    );
  }
}
