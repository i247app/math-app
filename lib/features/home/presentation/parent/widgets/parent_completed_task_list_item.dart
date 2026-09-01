import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/application/read_models/parent_room_read_model.dart';
import 'package:numi/features/home/domain/models/home_layout.dart';
import 'package:numi/features/profile/application/read_models/profile_display_read_model.dart';
import 'package:numi/shared/widgets/parent_tasks/parent_task_list_item.dart';
import 'package:numi/shared/widgets/parent_tasks/parent_task_score_ring.dart';

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
    final colors = context.themeColors;
    final exercise = completion.exercise;
    final score = ((completion.scorePercentage ?? 0) / 10).round().clamp(0, 10);
    final color = score >= 8 ? colors.success : colors.accent;

    return ParentTaskListItem(
      leading: ParentTaskScoreRing(score: score, color: color),
      title: roomExerciseTitle(context, exercise),
      childName: completion.child == null
          ? null
          : profileDisplayName(context, completion.child!),
      classroomName: roomClassName(context, completion.classroom),
      dateLabel: roomDateOnlyLabel(
        completion.gradedDt ?? completion.submittedDt ?? exercise?.createDt,
      ),
      onTap: onTap,
    );
  }
}
