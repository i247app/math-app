import 'package:flutter/material.dart';
import 'package:numi/features/home/home_api.dart';
import 'package:numi/features/home/widgets/home_profile_menu.dart';
import 'package:numi/features/home/parent/room/helpers/parent_room_helpers.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_icon_box.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_list_item.dart';

class ParentPendingTaskListItem extends StatelessWidget {
  const ParentPendingTaskListItem({
    super.key,
    required this.pending,
    this.onTap,
    this.isExpired = false,
  });

  final HomeLayoutPendingExercise pending;
  final VoidCallback? onTap;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final exercise = pending.exercise;
    final title = roomExerciseTitle(context, exercise);
    final childName = pending.child == null
        ? null
        : homeProfileDisplayName(context, pending.child!);
    final classroomName = roomClassName(context, pending.classroom);
    final accent = isExpired
        ? (
            color: const Color(0xFFFF7A1A),
            background: const Color(0xFFFFF0D8),
            icon: Icons.warning_amber_rounded,
            asset: null,
          )
        : roomPurposeListAccent(exercise?.purpose);

    return ParentTaskListItem(
      leading: ParentTaskIconBox(
        icon: accent.icon,
        asset: accent.asset,
        color: accent.color,
        backgroundColor: accent.background,
      ),
      title: title,
      childName: childName,
      classroomName: classroomName,
      dateLabel: roomDateOnlyLabel(exercise?.endDate ?? exercise?.createDt),
      onTap: onTap,
    );
  }
}
