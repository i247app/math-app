import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/widgets/score_progress_ring.dart';

class ParentTaskScoreRing extends StatelessWidget {
  const ParentTaskScoreRing({
    super.key,
    required this.score,
    required this.color,
  });

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ScoreProgressRing(
      progress: score <= 0 ? 0 : (score / 10).clamp(0.08, 1).toDouble(),
      color: color,
      trackColor: color.withValues(alpha: 0.12),
      size: 48,
      strokeWidth: 5,
      child: Text(
        '$score',
        style: TextStyle(
          color: color,
          fontSize: FontSize.xxxl,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
