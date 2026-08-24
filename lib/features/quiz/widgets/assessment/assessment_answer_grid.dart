import 'package:flutter/material.dart';

import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/features/quiz/widgets/assessment/assessment_answer_button.dart';

class AssessmentAnswerGrid extends StatelessWidget {
  const AssessmentAnswerGrid({
    super.key,
    required this.answers,
    required this.selectedAnswerLabel,
    required this.onSelected,
  });
  final List<QuizAnswer> answers;
  final String? selectedAnswerLabel;
  final ValueChanged<QuizAnswer> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: answers.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 96,
      ),
      itemBuilder: (context, index) {
        final answer = answers[index];
        return AssessmentAnswerButton(
          answer: answer,
          selected: answer.label == selectedAnswerLabel,
          onTap: () => onSelected(answer),
        );
      },
    );
  }
}
