part of '../../presentation/assessment_screen.dart';

class _AssessmentErrorState extends StatelessWidget {
  const _AssessmentErrorState({
    super.key,
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  final double scale;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72 * scale,
              height: 72 * scale,
              decoration: BoxDecoration(
                color: _assessmentPeach.withValues(alpha: 0.58),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: _assessmentRust,
                size: 34 * scale,
              ),
            ),
            SizedBox(height: 20 * scale),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _assessmentMuted,
                fontSize: 15 * scale,
                fontWeight: FontWeight.w800,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 24 * scale),
            SizedBox(
              width: 168 * scale,
              child: _BottomActionButton(
                label: context.getText(AppKeys.retryUpper),
                icon: Icons.refresh_rounded,
                foreground: const Color(0xFFBEFFF9),
                scale: scale,
                onTap: onRetry,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_assessmentTeal, Color(0xFF73F1E7)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
