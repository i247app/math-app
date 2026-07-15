import 'package:flutter/material.dart';

import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_date_parts_from_iso.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_entry_card.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_incomplete_badge.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_quiz_short_text.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_quiz_title.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_score_badge.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_score_colors.dart';

class HistoryQuizCard extends StatelessWidget {
  const HistoryQuizCard({
    super.key,
    required this.quiz,
    required this.scale,
    required this.onTap,
  });

  final GeneratedQuiz quiz;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = quiz.grading?.scorePercentage;
    return HistoryEntryCard(
      leading: percent == null
          ? HistoryIncompleteBadge(scale: scale)
          : HistoryScoreBadge(
              percentage: percent,
              colors: historyScoreColors(context, percent),
              scale: scale,
            ),
      dateParts: historyDatePartsFromIso(quiz.createDt),
      title: historyQuizTitle(context, quiz),
      subtitle: historyQuizShortText(quiz),
      scale: scale,
      onTap: onTap,
    );
  }
}
