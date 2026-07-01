part of '../../presentation/quiz_review_screen.dart';

class _QuizReviewQuestionNavigationBar extends StatelessWidget {
  const _QuizReviewQuestionNavigationBar({
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _QuizReviewNavButton(
              label: context.getText(AppKeys.previous),
              icon: Icons.chevron_left_rounded,
              filled: false,
              enabled: canGoPrevious,
              onTap: onPrevious,
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: _QuizReviewNavButton(
              label: context.getText(AppKeys.next),
              icon: Icons.chevron_right_rounded,
              filled: true,
              enabled: canGoNext,
              onTap: onNext,
              iconAfter: true,
            ),
          ),
        ],
      ),
    );
  }
}
