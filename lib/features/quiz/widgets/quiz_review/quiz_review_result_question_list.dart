part of 'package:numi/features/quiz/presentation/screens/quiz_review_screen.dart';

class _QuizReviewResultQuestionList extends StatelessWidget {
  const _QuizReviewResultQuestionList({
    required this.quiz,
    required this.selectedAnswers,
  });

  final GeneratedQuiz quiz;
  final Map<int, String> selectedAnswers;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < quiz.questions.length; index++) ...[
          _QuizReviewResultQuestionCard(
            question: quiz.questions[index],
            selectedLabel:
                selectedAnswers[quiz.questions[index].questionNumber],
          ),
          if (index != quiz.questions.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}
