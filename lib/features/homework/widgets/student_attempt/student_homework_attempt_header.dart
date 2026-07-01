part of '../../presentation/student_homework_attempt_screen.dart';

class _StudentHomeworkAttemptHeader extends StatelessWidget {
  const _StudentHomeworkAttemptHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32 * scale)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 80 * scale,
          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
          decoration: BoxDecoration(
            color: _homeworkAttemptMint.withValues(alpha: 0.84),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(32 * scale),
            ),
            boxShadow: [
              BoxShadow(
                color: _homeworkAttemptInk.withValues(alpha: 0.05),
                blurRadius: 2 * scale,
                offset: Offset(0, 1 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              QuizHeaderIconButton(
                icon: Icons.close_rounded,
                color: _homeworkAttemptTeal,
                scale: scale,
                circle: true,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Text(
                  context.getText(AppKeys.studentHomework),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _homeworkAttemptTeal,
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              QuizHeaderIconButton(
                icon: Icons.help_outline_rounded,
                color: _homeworkAttemptTeal,
                scale: scale,
                circle: true,
                onTap: HapticFeedback.selectionClick,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
