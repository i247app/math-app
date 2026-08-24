import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/features/quiz/widgets/learning_progress/learning_progress_chart.dart';

class LearningProgressChartCard extends StatelessWidget {
  const LearningProgressChartCard({
    super.key,
    required this.points,
    required this.onFilter,
    this.entryCount,
  });

  final List<QuizProgressPoint> points;
  final VoidCallback onFilter;
  final int? entryCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 12, 14),
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
          _ChartCardHeader(
            entryCount: entryCount ?? points.length,
            onFilter: onFilter,
          ),
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
  const _ChartCardHeader({required this.entryCount, required this.onFilter});

  final int entryCount;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                spacing: 7,
                children: [
                  Flexible(
                    child: Text(
                      context.getText(AppKeys.learningProgressScoreTitle),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: FontSize.large,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.info_outline_rounded,
                    color: colors.textMuted,
                    size: 18,
                  ),
                ],
              ),
              Text(
                context.formatText(AppKeys.learningProgressAssessmentCount, {
                  'count': entryCount,
                }),
                style: const TextStyle(
                  color: AppColors.textTeal,
                  fontSize: FontSize.small,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onFilter,
          icon: const Icon(Icons.tune_rounded, size: 20),
          label: Text(context.getText(AppKeys.learningProgressFilter)),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textTeal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            textStyle: const TextStyle(
              fontSize: FontSize.small,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
