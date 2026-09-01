import 'package:flutter/material.dart';

import 'package:numi/features/quiz/presentation/widgets/quiz_review/quiz_review_question_loading_section_state.dart';

class QuizReviewQuestionLoadingSection extends StatefulWidget {
  const QuizReviewQuestionLoadingSection({super.key, this.progress});

  final double? progress;

  @override
  State<QuizReviewQuestionLoadingSection> createState() =>
      QuizReviewQuestionLoadingSectionState();
}
