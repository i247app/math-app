import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:numi/features/home/home_api.dart';
import 'package:numi/features/home/widgets/home_profile_menu.dart';
import 'package:numi/features/home/parent/room/helpers/parent_room_helpers.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_date_label.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_icon_box.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_meta_badges.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_title.dart';

class ParentPendingTaskListItem extends StatelessWidget {
  const ParentPendingTaskListItem({
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

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            ParentTaskIconBox(
              icon: accent.icon,
              asset: accent.asset,
              color: accent.color,
              backgroundColor: accent.background,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ParentTaskMetaBadges(
                          childName: childName,
                          classroomName: classroomName,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ParentTaskDateLabel(
                        date: roomDateOnlyLabel(
                          exercise?.endDate ?? exercise?.createDt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ParentTaskTitle(title: title),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
