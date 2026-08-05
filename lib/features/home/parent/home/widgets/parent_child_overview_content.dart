import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/home/data/home_api.dart';
import 'package:numi/features/home/parent/home/models/parent_child_summary.dart';
import 'package:numi/features/home/parent/home/helpers/parent_child_dashboard_helpers.dart';
import 'package:numi/features/home/parent/home/models/parent_home_entrance_builder.dart';
import 'package:numi/features/home/parent/home/widgets/parent_home_error_card.dart';
import 'package:numi/features/home/parent/home/widgets/parent_home_refresh_label.dart';
import 'package:numi/features/home/parent/home/widgets/parent_teacher_messages_list.dart';
import 'package:numi/features/home/parent/shared/parent_home_helpers.dart';
import 'package:numi/features/home/widgets/home_math_squadron_preview_artwork.dart';
import 'package:numi/features/home/widgets/sections/promo_actions/promo_actions.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_completed_task_list_item.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_pending_task_list_item.dart';
import 'package:numi/features/profile/helpers/profile_display_helpers.dart';
import 'package:numi/shared/widgets/app_content_section.dart';
import 'package:numi/shared/widgets/app_responsive_card_group.dart';
import 'package:numi/shared/widgets/app_summary_card.dart';

class ParentChildOverviewContent extends StatelessWidget {
  const ParentChildOverviewContent({
    super.key,
    required this.summaries,
    required this.pendingExercises,
    required this.completions,
    required this.entranceBuilder,
    required this.onCompletionTap,
    required this.onViewTasks,
    required this.onViewResults,
    required this.onViewMessages,
    required this.onPromoActionTap,
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
  final VoidCallback onPromoActionTap;
  final bool isRefreshing;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final primarySummary = parentPrimarySummary(summaries);
    final primaryClass = _classCard(context, primarySummary);
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
          child: AppResponsiveCardGroup(children: [primaryClass]),
        ),
        if (pendingExercises.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: entranceBuilder(
              order: 1,
              child: AppContentSection(
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
                        Divider(height: 24, indent: 62, color: colors.border),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
        if (completions.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: entranceBuilder(
              order: 2,
              child: AppContentSection(
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
                        Divider(height: 24, indent: 62, color: colors.border),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: entranceBuilder(
            order: 3,
            markOnEnd: !showGameSuggestions,
            child: AppContentSection(
              title: context.getText(AppKeys.parentMessagesTitle),
              onViewAll: onViewMessages,
              child: ParentTeacherMessagesList(summaries: summaries),
            ),
          ),
        ),
        if (showGameSuggestions)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: entranceBuilder(
              order: 4,
              markOnEnd: true,
              child: PromoActionsSection(
                spacing: 12,
                children: [
                  PromoActionCard(
                    data: PromoActionData(
                      image: const AssetImage(
                        'assets/images/game_numi_farm_banner.png',
                      ),
                      backgroundColor: const Color(0xFFDDF3EE),
                      onTap: onPromoActionTap,
                    ),
                  ),
                  PromoActionCard(
                    data: PromoActionData(
                      child: const HomeMathSquadronPreviewArtwork(),
                      backgroundColor: const Color(0xFF111C4B),
                      onTap: onPromoActionTap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (isRefreshing)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: ParentHomeRefreshLabel(),
          ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ParentHomeErrorCard(
              message: errorMessage!,
              onRetry: onRetry,
            ),
          ),
      ],
    );
  }
}

Widget _classCard(BuildContext context, ParentChildSummary? summary) {
  final teacherName = summary?.classroom?.teacherName?.trim();

  return AppSummaryCard(
    label: summary == null
        ? context.getText(AppKeys.parentNoStudentTitle)
        : profileDisplayName(context, summary.profile),
    title: summary == null
        ? context.getText(AppKeys.parentNoClassroom)
        : parentClassroomName(context, summary),
    description: teacherName?.isNotEmpty == true
        ? teacherName!
        : context.getText(AppKeys.parentNoTeacher),
  );
}
