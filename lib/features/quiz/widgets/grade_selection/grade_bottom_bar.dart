part of '../../presentation/grade_selection_screen.dart';

class _GradeBottomBar extends StatelessWidget {
  const _GradeBottomBar({
    required this.scale,
    required this.onSkip,
    required this.onContinue,
  });

  final double scale;
  final VoidCallback onSkip;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 72 * scale,
          padding: EdgeInsets.fromLTRB(
            24 * scale,
            10 * scale,
            24 * scale,
            10 * scale,
          ),
          decoration: BoxDecoration(
            color: _gradeMint.withValues(alpha: 0.90),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 22 * scale,
                offset: Offset(0, -8 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 9,
                child: _PillActionButton(
                  label: context.getText(AppKeys.skipUpper),
                  background: _gradePeach,
                  foreground: _gradeRust,
                  scale: scale,
                  onPressed: onSkip,
                ),
              ),
              SizedBox(width: 20 * scale),
              Expanded(
                flex: 10,
                child: _PillActionButton(
                  label: context.getText(AppKeys.continueUpper),
                  icon: Icons.arrow_forward_rounded,
                  background: _gradeTeal,
                  foreground: Colors.white,
                  gradient: const LinearGradient(
                    colors: [_gradeTeal, Color(0xFF55E0D6)],
                  ),
                  scale: scale,
                  onPressed: onContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
