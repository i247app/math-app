import 'dart:convert';

import 'package:numi/features/exam/models/exam.dart';

/// A child's response. Option IDs are case sensitive and never display letters.
class ExamAnswerSelection {
  const ExamAnswerSelection({
    this.optionIds = const [],
    this.value,
    this.multiple = false,
  });

  final List<String> optionIds;
  final String? value;
  final bool multiple;

  bool get isEmpty => value == null ? optionIds.isEmpty : value!.trim().isEmpty;
  bool get isValid =>
      value == null ? optionIds.isNotEmpty : parseNumber(value!) != null;

  // String state is retained by the existing navigation and review widgets.
  // This representation is local UI state and is never sent to the API.
  String get stateValue =>
      value ?? (multiple ? jsonEncode(optionIds) : optionIds.firstOrNull ?? '');

  factory ExamAnswerSelection.fromState(ExamQuestion question, String state) {
    if (question.isNumericInput) return ExamAnswerSelection(value: state);
    if (question.isMultipleChoice) {
      final ids = (jsonDecode(state) as List).cast<String>();
      return ExamAnswerSelection(optionIds: ids, multiple: true);
    }
    return ExamAnswerSelection(optionIds: state.isEmpty ? const [] : [state]);
  }

  factory ExamAnswerSelection.fromSubmitted(
    ExamQuestion question,
    SubmitExamAnswer answer,
  ) => ExamAnswerSelection(
    optionIds: answer.selectedOptionIds,
    value: answer.value,
    multiple: question.isMultipleChoice,
  );

  SubmitExamAnswer submission(int questionNumber) => SubmitExamAnswer(
    questionNumber: questionNumber,
    optionIds: value == null ? List.unmodifiable(optionIds) : null,
    value: value,
  );

  bool? isCorrect(ExamQuestion question) {
    if (question.isNumericInput) {
      if (question.correctValues.isEmpty) return null;
      final number = parseNumber(value ?? '');
      if (number == null) return false;
      return question.correctValues.any((accepted) {
        final expected = parseNumber(accepted);
        return expected != null &&
            number.$1 * expected.$2 == expected.$1 * number.$2;
      });
    }
    final expected = correctIds(question).toSet();
    if (expected.isEmpty) return null;
    final selected = optionIds.toSet();
    return selected.length == expected.length && selected.containsAll(expected);
  }

  static List<String> correctIds(ExamQuestion question) =>
      question.correctOptionIds;

  static (BigInt, BigInt)? parseNumber(String input) {
    final parts = input.trim().replaceAll(',', '.').split('/');
    if (parts.length > 2) return null;
    (BigInt, BigInt)? decimal(String text) {
      text = text.trim();
      if (!RegExp(r'^[+-]?(?:\d+(?:\.\d*)?|\.\d+)$').hasMatch(text)) {
        return null;
      }
      final decimals = text.contains('.')
          ? text.length - text.indexOf('.') - 1
          : 0;
      return (
        BigInt.parse(text.replaceAll('.', '')),
        BigInt.from(10).pow(decimals),
      );
    }

    final numerator = decimal(parts.first);
    if (numerator == null) return null;
    if (parts.length == 1) return numerator;
    final denominator = decimal(parts.last);
    if (denominator == null || denominator.$1 == BigInt.zero) return null;
    return (numerator.$1 * denominator.$2, numerator.$2 * denominator.$1);
  }
}
