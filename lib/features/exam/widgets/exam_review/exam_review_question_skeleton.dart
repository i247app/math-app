import 'package:flutter/material.dart';

import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';

class ExamReviewQuestionSkeleton extends StatelessWidget {
  const ExamReviewQuestionSkeleton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 23),
          child: AppSkeletonBlock(color: color, height: 146, radius: 14),
        ),
        Column(
          spacing: 10,
          children: List.generate(
            4,
            (_) => AppSkeletonBlock(color: color, height: 59, radius: 12),
            growable: false,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 13, 20, 0),
          child: Row(
            spacing: 28,
            children: [
              Expanded(
                child: AppSkeletonBlock(color: color, height: 40, radius: 9),
              ),
              Expanded(
                child: AppSkeletonBlock(color: color, height: 40, radius: 9),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
