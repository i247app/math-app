part of '../../../home_screen.dart';

class _ParentAssessmentScoreBadge extends StatelessWidget {
  const _ParentAssessmentScoreBadge({
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
