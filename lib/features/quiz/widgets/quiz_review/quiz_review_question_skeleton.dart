import 'package:flutter/material.dart';

import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_skeleton_block.dart';

class QuizReviewQuestionSkeleton extends StatelessWidget {
  const QuizReviewQuestionSkeleton({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 23),
          child: QuizReviewSkeletonBlock(
            progress: progress,
            height: 146,
            borderRadius: 14,
          ),
        ),
        Column(
          spacing: 10,
          children: List.generate(
            4,
            (_) => QuizReviewSkeletonBlock(
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
                child: QuizReviewSkeletonBlock(
                  progress: progress,
                  height: 40,
                  borderRadius: 9,
                ),
              ),
              Expanded(
                child: QuizReviewSkeletonBlock(
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
