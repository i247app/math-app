part of '../../presentation/assessment_screen.dart';

class _AssessmentHeader extends StatelessWidget {
  const _AssessmentHeader({required this.scale});

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
            color: _assessmentMint.withValues(alpha: 0.84),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(32 * scale),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF253228).withValues(alpha: 0.05),
                blurRadius: 2 * scale,
                offset: Offset(0, 1 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              _HeaderIconButton(
                icon: Icons.close_rounded,
                scale: scale,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Text(
                  context.getText(AppKeys.aiChallenge),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _assessmentTeal,
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              _HeaderIconButton(
                icon: Icons.help_outline_rounded,
                scale: scale,
                onTap: HapticFeedback.selectionClick,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
