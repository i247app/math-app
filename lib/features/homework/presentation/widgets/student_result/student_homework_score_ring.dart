import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/score_progress_ring.dart';

class StudentHomeworkScoreRing extends StatelessWidget {
  const StudentHomeworkScoreRing({super.key, required this.scoreText});
  final String scoreText;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return ScoreDisplayRing(
      scoreText: scoreText,
      progress: 1,
      ringColor: colors.brandStrong,
      scoreColor: colors.success,
      trackColor: colors.brandStrong,
      fillColor: colors.elevatedSurface,
      labelColor: colors.textSecondary,
    );
  }
}
