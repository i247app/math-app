import 'package:flutter/material.dart';

import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_answer_list.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_question_card.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_question_navigation_bar.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_question_selector.dart';

class QuizReviewRetryQuestionView extends StatelessWidget {
  const QuizReviewRetryQuestionView({
    super.key,
    required this.questions,
    required this.selectedIndex,
    required this.question,
    required this.selectedAnswers,
    required this.onQuestionSelected,
    required this.onAnswerSelected,
    required this.onPrevious,
    required this.onNext,
  });

  final List<QuizQuestion> questions;
  final int selectedIndex;
  final QuizQuestion question;
  final Map<int, String> selectedAnswers;
  final ValueChanged<int> onQuestionSelected;
  final void Function(int questionNumber, String label) onAnswerSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizReviewQuestionSelector(
          questions: questions,
          selectedIndex: selectedIndex,
          onSelected: onQuestionSelected,
        ),
        const SizedBox(height: 20),
        QuizReviewQuestionCard(question: question),
        const SizedBox(height: 23),
        QuizReviewAnswerList(
          question: question,
          selectedLabel: selectedAnswers[question.questionNumber],
          onSelected: (label) =>
              onAnswerSelected(question.questionNumber, label),
        ),
        const SizedBox(height: 13),
        QuizReviewQuestionNavigationBar(
          canGoPrevious: selectedIndex > 0,
          canGoNext: selectedIndex < questions.length - 1,
          onPrevious: onPrevious,
          onNext: onNext,
        ),
      ],
    );
  }
}
