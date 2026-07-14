part of 'package:numi/features/quiz/presentation/screens/quiz_review_screen.dart';

class _QuizReviewRetryQuestionView extends StatelessWidget {
  const _QuizReviewRetryQuestionView({
    required this.questions,
    required this.selectedIndex,
    required this.question,
    required this.selectedAnswers,
    required this.onQuestionSelected,
    required this.onAnswerSelected,
    required this.onPrevious,
    required this.onNext,
  });

  final List<QuizQuestion> questions;
  final int selectedIndex;
  final QuizQuestion question;
  final Map<int, String> selectedAnswers;
  final ValueChanged<int> onQuestionSelected;
  final void Function(int questionNumber, String label) onAnswerSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuizReviewQuestionSelector(
          questions: questions,
          selectedIndex: selectedIndex,
          onSelected: onQuestionSelected,
        ),
        const SizedBox(height: 20),
        _QuizReviewQuestionCard(question: question),
        const SizedBox(height: 23),
        _QuizReviewAnswerList(
          question: question,
          selectedLabel: selectedAnswers[question.questionNumber],
          onSelected: (label) =>
              onAnswerSelected(question.questionNumber, label),
        ),
        const SizedBox(height: 13),
        _QuizReviewQuestionNavigationBar(
          canGoPrevious: selectedIndex > 0,
          canGoNext: selectedIndex < questions.length - 1,
          onPrevious: onPrevious,
          onNext: onNext,
        ),
      ],
    );
  }
}
