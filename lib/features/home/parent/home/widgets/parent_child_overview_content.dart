import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/home/home_api.dart';
import 'package:numi/features/home/parent/home/models/parent_child_summary.dart';
import 'package:numi/features/home/parent/home/helpers/parent_child_dashboard_helpers.dart';
import 'package:numi/features/home/parent/home/models/parent_home_entrance_builder.dart';
import 'package:numi/features/home/parent/home/widgets/parent_child_class_summary_card.dart';
import 'package:numi/features/home/parent/home/widgets/parent_dashboard_section.dart';
import 'package:numi/features/home/parent/home/widgets/parent_game_suggestions_row.dart';
import 'package:numi/features/home/parent/home/widgets/parent_home_error_card.dart';
import 'package:numi/features/home/parent/home/widgets/parent_home_refresh_label.dart';
import 'package:numi/features/home/parent/home/widgets/parent_teacher_messages_list.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_completed_task_list_item.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_pending_task_list_item.dart';

class ParentChildOverviewContent extends StatelessWidget {
  const ParentChildOverviewContent({
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

  final List<ParentChildSummary> summaries;
  final List<HomeLayoutPendingExercise> pendingExercises;
  final List<HomeLayoutRecentCompletion> completions;
  final ParentHomeEntranceBuilder entranceBuilder;
  final ValueChanged<HomeLayoutRecentCompletion> onCompletionTap;
  final VoidCallback onViewTasks;
  final VoidCallback onViewResults;
  final VoidCallback onViewMessages;
  final bool isRefreshing;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final primarySummary = parentPrimarySummary(summaries);
    final showGameSuggestions = pendingExercises.isEmpty || completions.isEmpty;
    final visiblePendingExercises = pendingExercises
        .take(2)
        .toList(growable: false);
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
                child: ParentChildClassSummaryCard(summary: primarySummary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (pendingExercises.isNotEmpty) ...[
          entranceBuilder(
            order: 1,
            child: ParentDashboardSection(
              title: context.getText(AppKeys.parentTasksTitle),
              onViewAll: pendingExercises.length > 2 ? onViewTasks : null,
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < visiblePendingExercises.length;
                    index++
                  ) ...[
                    ParentPendingTaskListItem(
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
            child: ParentDashboardSection(
              title: context.getText(AppKeys.assessmentResultTitle),
              onViewAll: completions.length > 2 ? onViewResults : null,
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < visibleCompletions.length;
                    index++
                  ) ...[
                    ParentCompletedTaskListItem(
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
          child: ParentDashboardSection(
            title: context.getText(AppKeys.parentMessagesTitle),
            onViewAll: onViewMessages,
            child: ParentTeacherMessagesList(summaries: summaries),
          ),
        ),
        if (showGameSuggestions) ...[
          const SizedBox(height: 14),
          entranceBuilder(
            order: 4,
            markOnEnd: true,
            child: const ParentGameSuggestionsRow(),
          ),
        ],
        if (isRefreshing) ...[
          const SizedBox(height: 8),
          const ParentHomeRefreshLabel(),
        ],
        if (errorMessage != null) ...[
          const SizedBox(height: 10),
          ParentHomeErrorCard(message: errorMessage!, onRetry: onRetry),
        ],
      ],
    );
  }
}