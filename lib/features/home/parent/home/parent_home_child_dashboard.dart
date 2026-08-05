import 'package:flutter/material.dart';
import 'package:numi/features/home/data/home_api.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/home/parent/home/widgets/parent_child_overview_skeleton.dart';
import 'package:numi/features/home/parent/home/parent_home_tab.dart';
import 'package:numi/features/home/parent/home/parent_learning_streak_content.dart';
import 'package:numi/features/home/parent/home/widgets/parent_child_overview_content.dart';
import 'package:numi/features/home/widgets/sections/learning_streak/learning_streak.dart';

extension ParentHomeChildDashboardView on ParentHomeContentState {
  Widget buildChildDashboard() {
    final colors = context.themeColors;
    final parent = homeLayout?.parent;
    final padding = EdgeInsets.fromLTRB(14, 10, 14, widget.bottomPadding + 18);

    return RefreshIndicator(
      color: colors.brandStrong,
      onRefresh: loadHome,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.homeHeader != null) widget.homeHeader!,
            Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isLoading && !hasLoadedHome)
                    const LearningStreakSkeleton()
                  else if (!isLoading)
                    homeEntrance(
                      mode: ParentHomeEntranceMode.childOverview,
                      order: 0,
                      child: LearningStreakCard(
                        data: parentLearningStreakContent(
                          context,
                          hasCompletedAssessment:
                              completedAssessments.isNotEmpty,
                        ),
                      ),
                    )
                  else
                    LearningStreakCard(
                      data: parentLearningStreakContent(
                        context,
                        hasCompletedAssessment: completedAssessments.isNotEmpty,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: isLoading && !hasLoadedHome
                        ? const ParentChildOverviewSkeleton()
                        : ParentChildOverviewContent(
                            summaries: childSummaries,
                            pendingExercises:
                                parent?.pendingExercises ??
                                const <HomeLayoutPendingExercise>[],
                            completions:
                                parent?.recentCompletions ??
                                const <HomeLayoutRecentCompletion>[],
                            entranceBuilder:
                                ({
                                  required child,
                                  order = 0,
                                  markOnEnd = false,
                                }) => homeEntrance(
                                  mode: ParentHomeEntranceMode.childOverview,
                                  child: child,
                                  order: order + 1,
                                  markOnEnd: markOnEnd,
                                ),
                            onCompletionTap: openCompletionResult,
                            onViewTasks: widget.onOpenClassroomTab,
                            onViewResults: widget.onOpenClassroomTab,
                            onViewMessages: widget.onOpenClassroomTab,
                            onPromoActionTap: widget.onOpenPracticeTab,
                            isRefreshing: isLoading && hasLoadedHome,
                            errorMessage: errorMessage,
                            onRetry: loadHome,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
