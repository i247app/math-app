import 'package:flutter/material.dart';

import 'package:numi/features/exam/widgets/exam_review/exam_review_question_loading_section_state.dart';

class ExamReviewQuestionLoadingSection extends StatefulWidget {
  const ExamReviewQuestionLoadingSection({super.key, this.progress});

  final double? progress;

  @override
  State<ExamReviewQuestionLoadingSection> createState() =>
      ExamReviewQuestionLoadingSectionState();
}
