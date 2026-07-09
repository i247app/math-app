import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/home_api.dart';
import 'package:numi/features/home/widgets/home_profile_menu.dart';
import 'package:numi/features/home/parent/room/helpers/parent_room_helpers.dart';
import 'package:numi/features/home/parent/room/widgets/parent_room_status_icon.dart';
import 'package:numi/features/home/parent/room/widgets/parent_room_task_header.dart';
import 'package:numi/features/home/parent/room/widgets/parent_room_task_shell.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_meta_chip.dart';

// ignore: unused_element
class _ParentRoomPendingCard extends StatelessWidget {
  const _ParentRoomPendingCard({
    required this.pending,
    required this.onTap,
    // ignore: unused_element_parameter
    this.compact = false,
    // ignore: unused_element_parameter
    this.isExpired = false,
  });

  final HomeLayoutPendingExercise pending;
  final VoidCallback onTap;
  final bool compact;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final exercise = pending.exercise;
    final title = roomExerciseTitle(context, exercise);
    final childName = pending.child == null
        ? null
        : homeProfileDisplayName(context, pending.child!);
    final classroomName = roomClassName(context, pending.classroom);
    final dateLabel = roomExerciseCreatedDate(exercise);
    final dueLabel = roomExerciseDueLabel(context, exercise);
    final purpose = roomPurposeLabel(context, exercise?.purpose);
    final dueSoon = roomExerciseDueSoon(exercise);
    final accent = isExpired
        ? (color: const Color(0xFFB91C1C), badge: const Color(0xFFFFE2E2))
        : dueSoon
        ? (color: const Color(0xFFFF7A1A), badge: const Color(0xFFFFF0D8))
        : roomPurposeAccent(exercise?.purpose);
    final statusLabel = isExpired
        ? context.getText(AppKeys.homeworkFailed)
        : dueSoon
        ? context.getText(AppKeys.homeworkDueSoon)
        : purpose;

    return ParentRoomTaskShell(
      accent: accent.color,
      compact: compact,
      onTap: onTap,
      leading: ParentRoomStatusIcon(
        icon: isExpired
            ? Icons.warning_amber_rounded
            : dueSoon
            ? Icons.notification_important_outlined
            : Icons.assignment_outlined,
        color: accent.color,
        backgroundColor: accent.badge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParentRoomTaskHeader(
            dateLabel: dateLabel,
            childName: childName,
            classroomName: classroomName,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF121B42),
                    fontSize: FontSize.normal,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
              ),
              ParentTaskMetaChip(
                label: statusLabel,
                color: accent.badge,
                textColor: accent.color,
                fontSize: FontSize.xxs,
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Divider(height: 1, color: Color(0xFFE7E4E4)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: Color(0xFF5D5D5D),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  dueLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5D5D5D),
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
