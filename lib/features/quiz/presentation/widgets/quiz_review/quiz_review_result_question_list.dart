import 'package:flutter/material.dart';

import 'package:numi/features/quiz/domain/models/quiz.dart';
import 'package:numi/features/quiz/presentation/widgets/quiz_review/quiz_review_result_question_card.dart';

class QuizReviewResultQuestionList extends StatelessWidget {
  const QuizReviewResultQuestionList({
    super.key,
    required this.quiz,
    required this.selectedAnswers,
  });

  final GeneratedQuiz quiz;
  final Map<int, String> selectedAnswers;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 14,
      children: quiz.questions
          .map(
            (question) => QuizReviewResultQuestionCard(
              question: question,
              selectedLabel: selectedAnswers[question.questionNumber],
            ),
          )
          .toList(growable: false),
    );
  }
}
