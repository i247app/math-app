import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:numi/features/home/home_api.dart';
import 'package:numi/features/home/widgets/home_profile_menu.dart';
import 'package:numi/features/home/parent/room/helpers/parent_room_helpers.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_date_label.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_meta_badges.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_score_ring.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_title.dart';

class ParentCompletedTaskListItem extends StatelessWidget {
  const ParentCompletedTaskListItem({
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

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            ParentTaskScoreRing(score: score, color: color),
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
                          childName: completion.child == null
                              ? null
                              : homeProfileDisplayName(
                                  context,
                                  completion.child!,
                                ),
                          classroomName: roomClassName(
                            context,
                            completion.classroom,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ParentTaskDateLabel(
                        date: roomDateOnlyLabel(
                          completion.gradedDt ??
                              completion.submittedDt ??
                              completion.exercise?.createDt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ParentTaskTitle(
                    title: roomExerciseTitle(context, exercise),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}