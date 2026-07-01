part of '../../presentation/quiz_review_screen.dart';

class _ResultQuestionList extends StatelessWidget {
  const _ResultQuestionList({
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
          _ResultQuestionCard(
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
