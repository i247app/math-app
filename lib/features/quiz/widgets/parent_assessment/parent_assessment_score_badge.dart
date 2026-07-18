import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/widgets/score_progress_ring.dart';

class ParentAssessmentScoreBadge extends StatelessWidget {
  const ParentAssessmentScoreBadge({
    super.key,
    required this.percentage,
    required this.color,
  });

  final int? percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: ScoreProgressRing(
        progress: percentage == null ? 0.0 : percentage!.clamp(0, 100) / 100,
        color: color,
        size: 48,
        strokeWidth: 5,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            percentage == null ? '--' : '${(percentage! / 10).round()}',
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: FontSize.xxxl,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
