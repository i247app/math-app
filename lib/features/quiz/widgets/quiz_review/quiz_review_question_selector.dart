part of '../../presentation/quiz_review_screen.dart';

class _QuizReviewQuestionSelector extends StatelessWidget {
  const _QuizReviewQuestionSelector({
    required this.questions,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<QuizQuestion> questions;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(questions.length, (index) {
            final selected = index == selectedIndex;
            return Padding(
              padding: EdgeInsets.only(
                right: index == questions.length - 1 ? 0 : 11,
              ),
              child: InkWell(
                onTap: () => onSelected(index),
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected ? quizReviewTeal : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: quizReviewTeal, width: 1.2),
                  ),
                  child: _QuizReviewCenteredText(
                    '${index + 1}',
                    color: selected ? Colors.white : quizReviewTeal,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
