part of '../../../home_screen.dart';

class _ParentTaskScoreRing extends StatelessWidget {
  const _ParentTaskScoreRing({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: score <= 0 ? 0 : (score / 10).clamp(0.08, 1),
            strokeWidth: 5,
            backgroundColor: color.withValues(alpha: 0.12),
            color: color,
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Text(
              '$score',
              style: TextStyle(
                color: color,
                fontSize: FontSize.xxxl,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
