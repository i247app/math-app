part of '../../presentation/assessment_screen.dart';

class _AssessmentBottomBar extends StatelessWidget {
  const _AssessmentBottomBar({
    required this.scale,
    required this.canGoBack,
    required this.isLastQuestion,
    required this.isSubmitting,
    required this.onBack,
    required this.onContinue,
  });

  final double scale;
  final bool canGoBack;
  final bool isLastQuestion;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 97 * scale,
          padding: EdgeInsets.fromLTRB(
            24 * scale,
            25 * scale,
            24 * scale,
            24 * scale,
          ),
          decoration: BoxDecoration(
            color: _assessmentMint.withValues(alpha: 0.90),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFCDE2CF).withValues(alpha: 0.30),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _BottomActionButton(
                  label: context.getText(AppKeys.previousQuestionUpper),
                  icon: Icons.arrow_back_rounded,
                  background: _assessmentPeach.withValues(alpha: 0.50),
                  foreground: _assessmentRust,
                  scale: scale,
                  onTap: canGoBack && !isSubmitting ? onBack : null,
                ),
              ),
              SizedBox(width: 48 * scale),
              Expanded(
                child: _BottomActionButton(
                  label: isSubmitting
                      ? context.getText(AppKeys.submittingUpper)
                      : isLastQuestion
                      ? context.getText(AppKeys.submitUpper)
                      : context.getText(AppKeys.continueUpper),
                  icon: isLastQuestion
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  foreground: const Color(0xFFBEFFF9),
                  scale: scale,
                  onTap: isSubmitting ? null : onContinue,
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
      ),
    );
  }
}
