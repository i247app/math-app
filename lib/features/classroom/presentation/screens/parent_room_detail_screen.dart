import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/homework/application/contracts/classroom_exercise_service.dart';
import 'package:numi/features/home/domain/models/home_layout.dart';
import 'package:numi/features/classroom/application/read_models/parent_room_read_model.dart';
import 'package:numi/features/classroom/models/parent_room_entry.dart';
import 'package:numi/features/classroom/presentation/screens/parent_message_contacts_screen.dart';
import 'package:numi/features/classroom/presentation/screens/parent_messages_screen.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_detail_hero.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_utilities_section.dart';
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
    final hasTasks = pendingExercises.isNotEmpty || expiredExercises.isNotEmpty;
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
                      onMembersTap: () => _openMembers(context),
                      onUtilityTap: () => parentRoomShowComingSoon(context),
                    ),
                  ),
                  if (hasTasks)
                    Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: AppContentSection(
                        title: context
                            .formatText(AppKeys.parentTasksCountTitle, {
                              'count':
                                  pendingExercises.length +
                                  expiredExercises.length,
                            }),
                        onViewAll: () => parentRoomShowComingSoon(context),
                        child: Column(
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

  void _openMembers(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ParentMessageContactsScreen(
          primaryTeacherName: roomTeacherName(context, entry),
        ),
      ),
    );
  }
}
