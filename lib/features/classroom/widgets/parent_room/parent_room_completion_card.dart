import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/domain/models/home_layout.dart';
import 'package:numi/features/profile/helpers/profile_display_helpers.dart';
import 'package:numi/features/classroom/helpers/parent_room_helpers.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_task_header.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_task_shell.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_task_meta_chip.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_task_score_ring.dart';

// ignore: unused_element
class _ParentRoomCompletionCard extends StatelessWidget {
  const _ParentRoomCompletionCard({
    required this.completion,
    required this.onTap,
    // ignore: unused_element_parameter
    this.compact = false,
  });

  final HomeLayoutRecentCompletion completion;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final exercise = completion.exercise;
    final title = roomExerciseTitle(context, exercise);
    final childName = completion.child == null
        ? null
        : profileDisplayName(context, completion.child!);
    final classroomName = roomClassName(context, completion.classroom);
    final purpose = roomPurposeLabel(context, exercise?.purpose);
    final accent = roomScoreAccent(completion.scorePercentage);
    final dateLabel = roomDateLabel(
      completion.gradedDt ?? completion.submittedDt ?? exercise?.createDt,
    );
    final score = ((completion.scorePercentage ?? 0) / 10).round().clamp(0, 10);

    return ParentRoomTaskShell(
      accent: accent,
      compact: compact,
      onTap: onTap,
      leading: ParentTaskScoreRing(score: score, color: accent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParentRoomTaskHeader(
            dateLabel: dateLabel,
            childName: childName,
            classroomName: classroomName,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 9),
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
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: ParentTaskMetaChip(
              label: purpose,
              color: accent.withValues(alpha: 0.13),
              textColor: accent,
              fontSize: FontSize.xxs,
            ),
          ),
        ],
      ),
    );
  }
}
