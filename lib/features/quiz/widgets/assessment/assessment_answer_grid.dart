import 'package:flutter/material.dart';

import 'package:numi/core/network/quiz_models.dart';
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
    final hasLongAnswer = answers.any(
      (answer) => answer.content.trim().length > 12,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: answers.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: hasLongAnswer ? 112 : 88,
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
