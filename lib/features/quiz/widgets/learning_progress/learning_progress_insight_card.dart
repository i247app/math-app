import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/network/quiz_models.dart';

class LearningProgressInsightCard extends StatelessWidget {
  const LearningProgressInsightCard({
    super.key,
    required this.points,
    this.summary,
  });

  final List<QuizProgressPoint> points;
  final QuizProgressSummary? summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trend = _trendFor(points, summary);
    final titleKey = trend.direction > 0
        ? AppKeys.learningProgressImprovingTitle
        : trend.direction < 0
        ? AppKeys.learningProgressDecliningTitle
        : AppKeys.learningProgressStableTitle;
    final message = _trendMessage(context, trend);
    final accent = isDark ? AppColors.brandTeal : AppColors.textTeal;
    final icon = trend.direction > 0
        ? Icons.star_rounded
        : trend.direction < 0
        ? Icons.trending_down_rounded
        : Icons.horizontal_rule_rounded;
    final iconColor = trend.direction > 0
        ? (isDark ? AppColors.neonGreen : AppColors.limeGreen)
        : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        spacing: 13,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.brandTealSolid,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 27),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  context.getText(titleKey),
                  style: TextStyle(
                    color: accent,
                    fontSize: FontSize.medium,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontSize.caption,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.brandTeal,
            size: 26,
          ),
        ],
      ),
    );
  }

  String _trendMessage(
    BuildContext context,
    ({int direction, double delta}) trend,
  ) {
    if (trend.direction > 0) {
      return context.formatText(AppKeys.learningProgressImprovingMessage, {
        'delta': trend.delta.abs().toStringAsFixed(1),
      });
    }
    if (trend.direction < 0) {
      return context.formatText(AppKeys.learningProgressDecliningMessage, {
        'delta': trend.delta.abs().toStringAsFixed(1),
      });
    }
    return context.getText(AppKeys.learningProgressStableMessage);
  }

  ({int direction, double delta}) _trendFor(
    List<QuizProgressPoint> values,
    QuizProgressSummary? summary,
  ) {
    if (summary != null) {
      final delta = summary.averageDelta;
      final normalizedTrend = summary.trend.trim().toUpperCase();
      final direction = delta > 0.05
          ? 1
          : delta < -0.05
          ? -1
          : switch (normalizedTrend) {
              'IMPROVING' || 'UP' => 1,
              'NEED_TO_TRY' || 'DECLINING' || 'DOWN' => -1,
              _ => 0,
            };
      return (direction: direction, delta: delta);
    }
    if (values.length < 2) {
      return (direction: 0, delta: 0);
    }
    final midpoint = math.max(1, values.length ~/ 2);
    final previous = values.take(midpoint).map(_score).toList();
    final recent = values.skip(midpoint).map(_score).toList();
    if (recent.isEmpty) {
      return (direction: 0, delta: 0);
    }
    final previousAverage =
        previous.reduce((value, score) => value + score) / previous.length;
    final recentAverage =
        recent.reduce((value, score) => value + score) / recent.length;
    final delta = recentAverage - previousAverage;
    return (
      direction: delta > 0.05
          ? 1
          : delta < -0.05
          ? -1
          : 0,
      delta: delta,
    );
  }

  double _score(QuizProgressPoint point) => point.score.clamp(0, 10);
}
