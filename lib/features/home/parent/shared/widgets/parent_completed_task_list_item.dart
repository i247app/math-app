import 'package:flutter/material.dart';
import 'package:numi/features/home/home_api.dart';
import 'package:numi/features/home/widgets/home_profile_menu.dart';
import 'package:numi/features/home/parent/room/helpers/parent_room_helpers.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_score_ring.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_list_item.dart';

class ParentCompletedTaskListItem extends StatelessWidget {
  const ParentCompletedTaskListItem({
    super.key,
    required this.completion,
    required this.onTap,
  });

  final HomeLayoutRecentCompletion completion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final exercise = completion.exercise;
    final score = ((completion.scorePercentage ?? 0) / 10).round().clamp(0, 10);
    final color = score >= 8
        ? const Color(0xFF07824C)
        : const Color(0xFFFF6B17);

    return ParentTaskListItem(
      leading: ParentTaskScoreRing(score: score, color: color),
      title: roomExerciseTitle(context, exercise),
      childName: completion.child == null
          ? null
          : homeProfileDisplayName(context, completion.child!),
      classroomName: roomClassName(context, completion.classroom),
      dateLabel: roomDateOnlyLabel(
        completion.gradedDt ?? completion.submittedDt ?? exercise?.createDt,
      ),
      onTap: onTap,
    );
  }
}
