import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/home/home_api.dart';
import 'package:numi_flutter/features/home/widgets/home_profile_menu.dart';
import 'package:numi_flutter/features/home/parent/room/helpers/parent_room_helpers.dart';
import 'package:numi_flutter/features/home/parent/room/widgets/parent_room_task_header.dart';
import 'package:numi_flutter/features/home/parent/room/widgets/parent_room_task_shell.dart';
import 'package:numi_flutter/features/home/parent/shared/widgets/parent_task_meta_chip.dart';
import 'package:numi_flutter/features/home/parent/shared/widgets/parent_task_score_ring.dart';

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
        : homeProfileDisplayName(context, completion.child!);
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
          const SizedBox(height: 9),
          Text(
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
          const SizedBox(height: 7),
          ParentTaskMetaChip(
            label: purpose,
            color: accent.withValues(alpha: 0.13),
            textColor: accent,
            fontSize: FontSize.xxs,
          ),
        ],
      ),
    );
  }
}