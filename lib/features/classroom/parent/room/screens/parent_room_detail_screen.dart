import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/home/data/home_api.dart';
import 'package:numi/features/quiz/presentation/screens/quiz_review_entry_screen.dart';
import 'package:numi/features/home/data/home_layout_mappers.dart';
import 'package:numi/features/classroom/parent/room/helpers/parent_room_helpers.dart';
import 'package:numi/features/classroom/parent/room/models/parent_room_entry.dart';
import 'package:numi/features/classroom/parent/room/widgets/parent_room_detail_hero.dart';
import 'package:numi/features/classroom/parent/room/widgets/parent_room_detail_shortcuts.dart';
import 'package:numi/features/classroom/parent/room/widgets/parent_room_detail_top_bar.dart';
import 'package:numi/features/classroom/parent/room/widgets/parent_room_list_section.dart';
import 'package:numi/features/classroom/parent/shared/widgets/parent_completed_task_list_item.dart';
import 'package:numi/features/classroom/parent/shared/widgets/parent_empty_task_line.dart';
import 'package:numi/features/classroom/parent/shared/widgets/parent_pending_task_list_item.dart';

class ParentRoomDetailScreen extends StatelessWidget {
  const ParentRoomDetailScreen({
    super.key,
    required this.entry,
    required this.pendingExercises,
    required this.expiredExercises,
    required this.completions,
    required this.exerciseService,
    required this.onRefreshLayout,
  });

  final ParentRoomEntry entry;
  final List<HomeLayoutPendingExercise> pendingExercises;
  final List<HomeLayoutPendingExercise> expiredExercises;
  final List<HomeLayoutRecentCompletion> completions;
  final ClassroomExerciseService exerciseService;
  final Future<void> Function() onRefreshLayout;

  @override
  Widget build(BuildContext context) {
    final title = roomClassName(context, entry.classroom);
    return Scaffold(
      backgroundColor: context.themeColors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ParentRoomDetailTopBar(
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
                    ParentRoomDetailHero(entry: entry),
                    const SizedBox(height: 18),
                    ParentRoomDetailShortcuts(
                      pendingCount:
                          pendingExercises.length + expiredExercises.length,
                      completedCount: completions.length,
                    ),
                    const SizedBox(height: 26),
                    ParentRoomListSection(
                      title: context.formatText(AppKeys.parentTasksCountTitle, {
                        'count':
                            pendingExercises.length + expiredExercises.length,
                      }),
                      onViewAll: () => parentRoomShowComingSoon(context),
                      child:
                          pendingExercises.isEmpty && expiredExercises.isEmpty
                          ? ParentEmptyTaskLine(
                              icon: Icons.assignment_turned_in_outlined,
                              text: context.getText(
                                AppKeys.studentNoHomeworkTitle,
                              ),
                            )
                          : Column(
                              children: [
                                for (final pending in pendingExercises) ...[
                                  ParentPendingTaskListItem(pending: pending),
                                  if (pending != pendingExercises.last ||
                                      expiredExercises.isNotEmpty)
                                    const Divider(
                                      height: 24,
                                      indent: 62,
                                      color: Color(0xFFE9EEF2),
                                    ),
                                ],
                                for (final expired in expiredExercises) ...[
                                  ParentPendingTaskListItem(
                                    pending: expired,
                                    isExpired: true,
                                    onTap: () =>
                                        showExpiredExerciseMessage(context),
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
                    ParentRoomListSection(
                      title: context.getText(AppKeys.assessmentResultTitle),
                      onViewAll: () => parentRoomShowComingSoon(context),
                      child: completions.isEmpty
                          ? ParentEmptyTaskLine(
                              icon: Icons.fact_check_outlined,
                              text: context.getText(
                                AppKeys.noCompletedHomeworkTitle,
                              ),
                            )
                          : Column(
                              children: [
                                for (final completion in completions) ...[
                                  ParentCompletedTaskListItem(
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
    final quiz = quizFromRecentCompletion(completion);
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
