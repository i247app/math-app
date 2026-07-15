import 'package:flutter/material.dart';
import 'package:numi/features/home/data/home_api.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/profile/helpers/profile_display_helpers.dart';
import 'package:numi/features/classroom/parent/room/helpers/parent_room_helpers.dart';
import 'package:numi/features/classroom/parent/shared/widgets/parent_task_icon_box.dart';
import 'package:numi/features/classroom/parent/shared/widgets/parent_task_list_item.dart';

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
    final colors = context.themeColors;
    final exercise = pending.exercise;
    final title = roomExerciseTitle(context, exercise);
    final childName = pending.child == null
        ? null
        : profileDisplayName(context, pending.child!);
    final classroomName = roomClassName(context, pending.classroom);
    final accent = isExpired
        ? (
            color: colors.warning,
            background: colors.warningSurface,
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
