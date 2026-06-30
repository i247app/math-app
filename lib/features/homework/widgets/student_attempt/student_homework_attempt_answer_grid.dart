part of '../../presentation/student_homework_attempt_screen.dart';

class _StudentHomeworkAttemptAnswerGrid extends StatelessWidget {
  const _StudentHomeworkAttemptAnswerGrid({
    required this.scale,
    required this.answers,
    required this.selectedAnswerLabel,
    required this.onSelected,
  });

  final double scale;
  final List<_StudentHomeworkAttemptAnswer> answers;
  final String? selectedAnswerLabel;
  final ValueChanged<_StudentHomeworkAttemptAnswer> onSelected;

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
        mainAxisExtent: 96 * scale,
      ),
      itemBuilder: (context, index) {
        final answer = answers[index];
        return _StudentHomeworkAttemptAnswerButton(
          answer: answer,
          selected: answer.label == selectedAnswerLabel,
          scale: scale,
          onTap: () => onSelected(answer),
        );
      },
    );
  }
}
