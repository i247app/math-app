import 'package:flutter/material.dart';

import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_answer_tile.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_correct_answer_label.dart';

class ExamReviewAnswerList extends StatelessWidget {
  const ExamReviewAnswerList({
    super.key,
    required this.question,
    required this.selectedLabel,
    this.onSelected,
    this.showCorrectAnswer = false,
  });

  final ExamQuestion question;
  final String? selectedLabel;
  final ValueChanged<String>? onSelected;
  final bool showCorrectAnswer;

  @override
  Widget build(BuildContext context) {
    final correctLabel = examReviewCorrectAnswerLabel(question);

    return Column(
      spacing: 10,
      children: question.answers
          .map(
            (answer) => ExamReviewAnswerTile(
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
