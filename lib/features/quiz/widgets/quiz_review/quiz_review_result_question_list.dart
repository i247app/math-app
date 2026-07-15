import 'package:flutter/material.dart';

import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_result_question_card.dart';

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
      children: [
        for (var index = 0; index < quiz.questions.length; index++) ...[
          QuizReviewResultQuestionCard(
            question: quiz.questions[index],
            selectedLabel:
                selectedAnswers[quiz.questions[index].questionNumber],
          ),
          if (index != quiz.questions.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}
