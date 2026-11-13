import 'package:flutter/material.dart';

import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_answer_button.dart';

class AssessmentAnswerGrid extends StatelessWidget {
  const AssessmentAnswerGrid({
    super.key,
    required this.options,
    required this.selectedAnswerLabel,
    this.selectedAnswerFeedbackCorrect,
    this.dense = false,
    this.denseRowHeight = denseRowMinHeight,
    required this.onSelected,
    this.renderLatex = false,
    this.selectedOptionIds,
    this.showLetters = true,
  });
  static const double denseRowMinHeight = 52;
  static const double denseRowMaxHeight = 76;
  static const double denseRowSpacing = 6;

  final List<ExamAnswer> options;
  final String? selectedAnswerLabel;
  final bool? selectedAnswerFeedbackCorrect;
  final bool dense;
  final double denseRowHeight;
  final ValueChanged<ExamAnswer> onSelected;
  final bool renderLatex;
  final Set<String>? selectedOptionIds;
  final bool showLetters;

  bool _selected(ExamAnswer answer) =>
      selectedOptionIds?.contains(answer.id) ??
      answer.id == selectedAnswerLabel;
  String _displayLabel(int index) =>
      showLetters ? String.fromCharCode(65 + index) : '';

  @override
  Widget build(BuildContext context) {
    final hasOnlyCompactAnswers =
        options.isNotEmpty &&
        options.every(
          (answer) =>
              answer.imageUrl == null &&
              (isNumericAssessmentContent(answer.text) ||
                  isIconAssessmentContent(answer.text)),
        );
    final hasLongNumericAnswer = options.any(
      (answer) => RegExp(r'\d').allMatches(answer.text).length >= 4,
    );
    final useCompactGrid =
        !renderLatex && hasOnlyCompactAnswers && !hasLongNumericAnswer;

    if (!useCompactGrid) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < options.length; index++) ...[
            AssessmentAnswerButton(
              answer: options[index],
              displayLabel: _displayLabel(index),
              renderLatex: renderLatex,
              selected: _selected(options[index]),
              feedbackCorrect: _selected(options[index])
                  ? selectedAnswerFeedbackCorrect
                  : null,
              dense: dense,
              denseHeight: denseRowHeight,
              onTap: () => onSelected(options[index]),
            ),
            if (index < options.length - 1)
              SizedBox(height: dense ? denseRowSpacing : 8),
          ],
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: dense ? 12 : 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 90,
      ),
      itemBuilder: (context, index) {
        final answer = options[index];
        return AssessmentAnswerButton(
          answer: answer,
          displayLabel: _displayLabel(index),
          compact: true,
          dense: dense,
          denseHeight: denseRowHeight,
          selected: _selected(answer),
          feedbackCorrect: _selected(answer)
              ? selectedAnswerFeedbackCorrect
              : null,
          onTap: () => onSelected(answer),
        );
      },
    );
  }
}
