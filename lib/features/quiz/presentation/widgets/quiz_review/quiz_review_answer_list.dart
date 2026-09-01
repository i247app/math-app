import 'package:flutter/material.dart';

import 'package:numi/features/quiz/domain/models/quiz.dart';
import 'package:numi/features/quiz/presentation/widgets/quiz_review/quiz_review_answer_tile.dart';
import 'package:numi/features/quiz/presentation/widgets/quiz_review/quiz_review_correct_answer_label.dart';

class QuizReviewAnswerList extends StatelessWidget {
  const QuizReviewAnswerList({
    super.key,
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
    final correctLabel = quizReviewCorrectAnswerLabel(question);

    return Column(
      spacing: 10,
      children: question.answers
          .map(
            (answer) => QuizReviewAnswerTile(
              answer: answer,
              selectedLabel: selectedLabel,
              correctLabel: correctLabel,
              showCorrectAnswer: showCorrectAnswer,
              onTap: onSelected == null
                  ? null
                  : () => onSelected!(answer.label),
            ),
          )
          .toList(growable: false),
    );
  }
}
