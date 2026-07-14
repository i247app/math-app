part of 'package:numi/features/quiz/presentation/screens/quiz_review_screen.dart';

class _QuizReviewModeTabs extends StatelessWidget {
  const _QuizReviewModeTabs({
    required this.selectedMode,
    required this.onSelected,
  });

  final QuizReviewMode selectedMode;
  final ValueChanged<QuizReviewMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _QuizReviewModeTabButton(
              label: context.getText(AppKeys.testAgain),
              selected: selectedMode == QuizReviewMode.retry,
              onTap: () => onSelected(QuizReviewMode.retry),
            ),
          ),
          Expanded(
            child: _QuizReviewModeTabButton(
              label: context.getText(AppKeys.viewResult),
              selected: selectedMode == QuizReviewMode.result,
              onTap: () => onSelected(QuizReviewMode.result),
            ),
          ),
        ],
      ),
    );
  }
}
