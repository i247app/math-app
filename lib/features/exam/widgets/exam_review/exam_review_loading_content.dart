import 'package:flutter/material.dart';

import 'package:numi/features/exam/widgets/exam_review/exam_review_question_skeleton.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

class ExamReviewLoadingContent extends StatelessWidget {
  const ExamReviewLoadingContent({super.key});

  @override
  Widget build(BuildContext context) => AppSkeletonLoader(
    builder: (context, color) => SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppSkeletonBlock(color: color, height: 44, radius: 12),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: AppSkeletonBlock(color: color, height: 94, radius: 14),
          ),
          ExamReviewQuestionSkeleton(color: color),
        ],
      ),
    ),
  );
}
