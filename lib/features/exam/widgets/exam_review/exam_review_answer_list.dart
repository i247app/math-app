import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/models/exam_answer_selection.dart';
import 'package:numi/features/exam/widgets/shared/exam_numeric_input.dart';
import 'package:flutter/material.dart';

import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_answer_tile.dart';

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
    if (question.isNumericInput && onSelected != null) {
      return ExamNumericInput(
        key: ValueKey('review-numeric-${question.questionNumber}'),
        value: selectedLabel ?? '',
        onChanged: onSelected!,
      );
    }
    if (question.isNumericInput || question.options.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(
            context.formatText(AppKeys.examYourAnswer, {
              'answer': selectedLabel ?? question.reviewChildText ?? '—',
            }),
          ),
          if (showCorrectAnswer)
            Text(
              context.formatText(AppKeys.answer, {
                'answer':
                    question.reviewCorrectText ??
                    question.correctValues.join(' | '),
              }),
            ),
        ],
      );
    }
    final selectedIds = selectedLabel == null
        ? const <String>[]
        : ExamAnswerSelection.fromState(question, selectedLabel!).optionIds;
    final correctIds = ExamAnswerSelection.correctIds(question);

    return Column(
      spacing: 10,
      children: [
        if (question.isMultipleChoice && onSelected != null)
          Text(context.getText(AppKeys.examChooseMultiple)),
        for (final (index, answer) in question.options.indexed)
          ExamReviewAnswerTile(
            answer: answer,
            displayLabel: question.isTrueFalse
                ? ''
                : String.fromCharCode(65 + index),
            renderLatex: question.isFraction,
            selectedLabel: selectedIds.contains(answer.id) ? answer.id : null,
            correctLabel: correctIds.contains(answer.id) ? answer.id : null,
            showCorrectAnswer: showCorrectAnswer,
            onTap: onSelected == null ? null : () => onSelected!(answer.id),
          ),
      ],
    );
  }
}
