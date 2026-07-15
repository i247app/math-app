import 'package:flutter/material.dart';

import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/features/quiz/helpers/history_homework_date_text.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_date_parts_from_iso.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_entry_card.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_homework_score_percentage.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_homework_short_text.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_homework_title.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_score_badge.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_score_colors.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_submitted_badge.dart';

class HistoryHomeworkCard extends StatelessWidget {
  const HistoryHomeworkCard({
    super.key,
    required this.exercise,
    required this.scale,
    required this.onTap,
  });

  final ClassroomExercise exercise;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percentage = historyHomeworkScorePercentage(exercise);
    return HistoryEntryCard(
      leading: percentage == null
          ? HistorySubmittedBadge(scale: scale)
          : HistoryScoreBadge(
              percentage: percentage,
              colors: historyScoreColors(context, percentage),
              scale: scale,
            ),
      dateParts: historyDatePartsFromIso(historyHomeworkDateText(exercise)),
      title: historyHomeworkTitle(context, exercise),
      subtitle: historyHomeworkShortText(context, exercise),
      scale: scale,
      onTap: onTap,
    );
  }
}
