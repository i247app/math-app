part of '../../presentation/quiz_review_screen.dart';

class _QuizReviewAnswerList extends StatelessWidget {
  const _QuizReviewAnswerList({
    required this.question,
    required this.selectedLabel,
    this.onSelected,
    this.showCorrectAnswer = false,
  });

  final QuizQuestion question;
  final String? selectedLabel;
  final ValueChanged<String>? onSelected;
  final bool showCorrectAnswer;

  @override
  Widget build(BuildContext context) {
    final correctLabel = _quizReviewCorrectAnswerLabel(question);

    return Column(
      children: [
        for (final answer in question.answers) ...[
          _QuizReviewAnswerTile(
            answer: answer,
            selectedLabel: selectedLabel,
            correctLabel: correctLabel,
            showCorrectAnswer: showCorrectAnswer,
            onTap: onSelected == null ? null : () => onSelected!(answer.label),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
