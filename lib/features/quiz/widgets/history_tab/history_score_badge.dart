part of '../../history_tab.dart';

class _HistoryScoreBadge extends StatelessWidget {
  const _HistoryScoreBadge({
    required this.percentage,
    required this.colors,
    required this.scale,
  });

  final int percentage;
  final _HistoryScoreBadgeColors colors;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final scoreOutOf10 = (percentage / 10).round();
    return SizedBox(
      width: 56 * scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScoreProgressRing(
            progress: percentage.clamp(0, 100) / 100,
            color: colors.foreground,
            size: 48 * scale,
            strokeWidth: 5 * scale,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$scoreOutOf10/10',
                maxLines: 1,
                style: TextStyle(
                  color: colors.foreground,
                  fontSize: FontSize.caption * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          SizedBox(height: 7 * scale),
          Text(
            colors.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.foreground,
              fontSize: FontSize.caption * 0.77 * scale,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
