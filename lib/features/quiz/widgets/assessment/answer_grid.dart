part of '../../presentation/assessment_screen.dart';

class _AnswerGrid extends StatelessWidget {
  const _AnswerGrid({
    required this.scale,
    required this.answers,
    required this.selectedAnswerLabel,
    required this.onSelected,
  });

  final double scale;
  final List<QuizAnswer> answers;
  final String? selectedAnswerLabel;
  final ValueChanged<QuizAnswer> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: answers.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16 * scale,
        crossAxisSpacing: 16 * scale,
        mainAxisExtent: 88 * scale,
      ),
      itemBuilder: (context, index) {
        final answer = answers[index];
        return _AnswerButton(
          answer: answer,
          selected: answer.label == selectedAnswerLabel,
          scale: scale,
          onTap: () => onSelected(answer),
        );
      },
    );
  }
}
