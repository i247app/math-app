import 'package:flutter/material.dart';

import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_result_question_card.dart';

class ExamReviewResultQuestionList extends StatelessWidget {
  const ExamReviewResultQuestionList({
    super.key,
    required this.exam,
    required this.selectedAnswers,
  });

  final GeneratedExam exam;
  final Map<int, String> selectedAnswers;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 14,
      children: exam.questions
          .map(
            (question) => ExamReviewResultQuestionCard(
              question: question,
              selectedLabel: selectedAnswers[question.questionNumber],
            ),
          )
          .toList(growable: false),
    );
  }
}
