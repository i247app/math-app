part of '../../../home_screen.dart';

class _ParentAssessmentScoreBadge extends StatelessWidget {
  const _ParentAssessmentScoreBadge({
    required this.percentage,
    required this.color,
    required this.label,
    required this.scale,
  });

  final int? percentage;
  final Color color;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56 * scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScoreProgressRing(
            progress: percentage == null
                ? 0.0
                : percentage!.clamp(0, 100) / 100,
            color: color,
            size: 48 * scale,
            strokeWidth: 5 * scale,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                percentage == null ? '--' : '${(percentage! / 10).round()}/10',
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: FontSize.caption * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
          SizedBox(height: 7 * scale),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: FontSize.caption * 0.77 * scale,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}
