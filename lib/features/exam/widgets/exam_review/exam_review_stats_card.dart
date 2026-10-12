import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/helpers/exam_review_answers.dart';
import 'package:numi/features/exam/helpers/exam_review_formatters.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_card.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_stat_item.dart';

class ExamReviewStatsCard extends StatelessWidget {
  const ExamReviewStatsCard({
    super.key,
    required this.exam,
    this.showTime = true,
  });

  final GeneratedExam exam;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final total = exam.grading?.totalQuestions ?? exam.questions.length;
    final correct =
        exam.grading?.correctNumber ?? examReviewComputedCorrectCount(exam);
    final wrong = total > correct ? total - correct : 0;
    final time = examReviewTimeLabel(exam);

    final items = <Widget>[
      ExamReviewStatItem(
        icon: Icons.assignment_outlined,
        iconColor: colors.primaryAction,
        iconBackground: colors.infoSurface,
        valueColor: colors.primaryAction,
        value: '$total',
        label: context.getText(AppKeys.totalQuestions),
      ),
      ExamReviewStatItem(
        icon: Icons.check_circle_outline_rounded,
        iconColor: colors.primaryAction,
        iconBackground: colors.successSurface,
        valueColor: colors.primaryAction,
        value: '$correct',
        label: context.getText(AppKeys.correct),
      ),
      ExamReviewStatItem(
        icon: Icons.cancel_outlined,
        iconColor: colors.error,
        iconBackground: colors.errorSurface,
        valueColor: colors.error,
        value: '$wrong',
        label: context.getText(AppKeys.incorrect),
      ),
      if (showTime)
        ExamReviewStatItem(
          icon: Icons.schedule_rounded,
          iconColor: colors.warning,
          iconBackground: colors.warningSurface,
          valueColor: colors.warning,
          value: time,
          label: context.getText(AppKeys.time),
        ),
    ];
    return ExamReviewCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale =
              MediaQuery.textScalerOf(context).scale(FontSize.xxs) /
              FontSize.xxs;
          final minimumWidth = 66 * textScale.clamp(1.0, 1.5);
          final columns = (constraints.maxWidth / minimumWidth).floor().clamp(
            1,
            items.length,
          );
          return Wrap(
            runSpacing: 16,
            children: [
              for (final item in items)
                SizedBox(width: constraints.maxWidth / columns, child: item),
            ],
          );
        },
      ),
    );
  }
}
