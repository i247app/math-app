import 'package:flutter/material.dart';

import 'package:numi/features/quiz/models/quiz.dart';
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
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: QuizReviewQuestionSelector(
            questions: questions,
            selectedIndex: selectedIndex,
            onSelected: onQuestionSelected,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 23),
          child: QuizReviewQuestionCard(question: question),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 13),
          child: QuizReviewAnswerList(
            question: question,
            selectedLabel: selectedAnswers[question.questionNumber],
            onSelected: (label) =>
                onAnswerSelected(question.questionNumber, label),
          ),
        ),
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
