import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/home/data/home_api.dart';
import 'package:numi/features/classroom/helpers/parent_room_helpers.dart';
import 'package:numi/features/classroom/models/parent_room_entry.dart';
import 'package:numi/features/classroom/presentation/screens/parent_messages_screen.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_detail_hero.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_utilities_section.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_empty_task_line.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_pending_task_list_item.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/widgets/app_content_section.dart';

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
      body: Column(
        children: [
          PageHeader(
            title: title,
            backgroundColor: context.themeColors.elevatedSurface,
            actionWidth: 52,
            horizontalPadding: 12,
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              color: context.themeColors.brandStrong,
              tooltip: context.getText(AppKeys.back),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                14,
                14,
                14,
                MediaQuery.paddingOf(context).bottom + 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ParentRoomDetailHero(entry: entry),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ParentRoomUtilitiesSection(
                      onMessageTap: () => _openMessages(context),
                      onUtilityTap: () => parentRoomShowComingSoon(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: AppContentSection(
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openMessages(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ParentMessagesScreen(
          className: roomClassName(context, entry.classroom),
          teacherName: roomTeacherName(context, entry),
        ),
      ),
    );
  }
}
