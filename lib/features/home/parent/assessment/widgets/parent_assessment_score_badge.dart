import 'package:flutter/material.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/shared/widgets/score_progress_ring.dart';

class ParentAssessmentScoreBadge extends StatelessWidget {
  const ParentAssessmentScoreBadge({
    super.key,
    required this.percentage,
    required this.color,
    required this.scale,
  });

  final int? percentage;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56 * scale,
      child: ScoreProgressRing(
        progress: percentage == null ? 0.0 : percentage!.clamp(0, 100) / 100,
        color: color,
        size: 48 * scale,
        strokeWidth: 5 * scale,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            percentage == null ? '--' : '${(percentage! / 10).round()}',
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: FontSize.xxxl * scale,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
