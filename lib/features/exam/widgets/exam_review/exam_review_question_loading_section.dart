import 'package:flutter/material.dart';

import 'package:numi/features/exam/widgets/exam_review/exam_review_question_skeleton.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

class ExamReviewQuestionLoadingSection extends StatelessWidget {
  const ExamReviewQuestionLoadingSection({super.key});

  @override
  Widget build(BuildContext context) => AppSkeletonLoader(
    builder: (context, color) => ExamReviewQuestionSkeleton(color: color),
  );
}
