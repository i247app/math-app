import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/learning_progress/learning_progress_chart.dart';

class LearningProgressChartCard extends StatelessWidget {
  const LearningProgressChartCard({
    super.key,
    required this.points,
    this.entryCount,
  });

  final List<ExamProgressPoint> points;
  final int? entryCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 18),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          _ChartCardHeader(entryCount: entryCount ?? points.length),
          if (points.isEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 280),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    context.getText(AppKeys.learningProgressNoData),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: FontSize.medium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          else
            LearningProgressChart(points: points),
        ],
      ),
    );
  }
}

class _ChartCardHeader extends StatelessWidget {
  const _ChartCardHeader({required this.entryCount});

  final int entryCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.getText(AppKeys.learningProgressScoreTitle),
                    maxLines: 1,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: FontSize.compact,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  context.formatText(AppKeys.learningProgressAssessmentCount, {
                    'count': entryCount,
                  }),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.bar_chart_rounded, color: colors.brandStrong, size: 22),
          const SizedBox(width: 4),
          Text(
            context.getText(AppKeys.learningProgressTestLegend),
            style: TextStyle(
              color: colors.brandStrong,
              fontSize: FontSize.xxs,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
