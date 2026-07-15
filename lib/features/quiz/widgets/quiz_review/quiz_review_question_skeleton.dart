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
        QuizReviewSkeletonBlock(
          progress: progress,
          height: 146,
          borderRadius: 14,
        ),
        const SizedBox(height: 23),
        for (var index = 0; index < 4; index++) ...[
          QuizReviewSkeletonBlock(
            progress: progress,
            height: 59,
            borderRadius: 12,
          ),
          if (index != 3) const SizedBox(height: 10),
        ],
        const SizedBox(height: 13),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: QuizReviewSkeletonBlock(
                  progress: progress,
                  height: 40,
                  borderRadius: 9,
                ),
              ),
              const SizedBox(width: 28),
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
