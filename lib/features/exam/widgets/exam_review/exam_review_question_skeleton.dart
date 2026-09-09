import 'package:flutter/material.dart';

import 'package:numi/features/exam/widgets/exam_review/exam_review_skeleton_block.dart';

class ExamReviewQuestionSkeleton extends StatelessWidget {
  const ExamReviewQuestionSkeleton({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 23),
          child: ExamReviewSkeletonBlock(
            progress: progress,
            height: 146,
            borderRadius: 14,
          ),
        ),
        Column(
          spacing: 10,
          children: List.generate(
            4,
            (_) => ExamReviewSkeletonBlock(
              progress: progress,
              height: 59,
              borderRadius: 12,
            ),
            growable: false,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 13, 20, 0),
          child: Row(
            spacing: 28,
            children: [
              Expanded(
                child: ExamReviewSkeletonBlock(
                  progress: progress,
                  height: 40,
                  borderRadius: 9,
                ),
              ),
              Expanded(
                child: ExamReviewSkeletonBlock(
                  progress: progress,
                  height: 40,
                  borderRadius: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
