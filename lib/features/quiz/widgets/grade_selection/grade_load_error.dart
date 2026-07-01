part of '../../presentation/grade_selection_screen.dart';

class _GradeLoadError extends StatelessWidget {
  const _GradeLoadError({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  final double scale;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28 * scale),
      ),
      child: Column(
        children: [
          Icon(Icons.school_outlined, color: _gradeTeal, size: 34 * scale),
          SizedBox(height: 12 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _gradeInk,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w800,
              height: 1.3,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 14 * scale),
          TextButton(
            onPressed: onRetry,
            child: Text(
              context.getText(AppKeys.retryUpper),
              style: TextStyle(
                color: _gradeTeal,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
