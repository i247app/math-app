part of '../../presentation/assessment_screen.dart';

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.answer,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final QuizAnswer answer;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? _assessmentTeal
        : Colors.black.withValues(alpha: 0);
    final textColor = selected ? _assessmentTeal : _assessmentInk;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(32 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32 * scale),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32 * scale),
            border: Border.all(color: borderColor, width: 2 * scale),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF73F1E7).withValues(alpha: 0.20),
                      spreadRadius: 4 * scale,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 6 * scale,
                      offset: Offset(0, 4 * scale),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2 * scale,
                      offset: Offset(0, 1 * scale),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                answer.content,
                style: TextStyle(
                  color: textColor,
                  fontSize: 30 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 8 * scale : 0,
                height: selected ? 12 * scale : 0,
                padding: EdgeInsets.only(top: 4 * scale),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: _assessmentTeal,
                    shape: BoxShape.circle,
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
