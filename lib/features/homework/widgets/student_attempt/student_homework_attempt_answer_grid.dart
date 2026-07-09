import 'package:flutter/material.dart';

import 'package:numi/features/homework/widgets/student_attempt/student_homework_attempt_answer_button.dart';
import 'package:numi/features/homework/widgets/student_attempt/student_homework_attempt_helpers.dart';

class StudentHomeworkAttemptAnswerGrid extends StatelessWidget {
  const StudentHomeworkAttemptAnswerGrid({
    super.key,
    required this.scale,
    required this.answers,
    required this.selectedAnswerLabel,
    required this.onSelected,
  });

  final double scale;
  final List<StudentHomeworkAttemptAnswer> answers;
  final String? selectedAnswerLabel;
  final ValueChanged<StudentHomeworkAttemptAnswer> onSelected;

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
        return StudentHomeworkAttemptAnswerButton(
          answer: answer,
          selected: answer.label == selectedAnswerLabel,
          scale: scale,
          onTap: () => onSelected(answer),
        );
      },
    );
  }
}
