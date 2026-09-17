import 'package:flutter/material.dart';

import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

class AssessmentQuestionSkeleton extends StatelessWidget {
  const AssessmentQuestionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonLoader(
      builder: (context, color) {
        return Column(
          key: const ValueKey('assessment-question-skeleton'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSkeletonBlock(
              height: 196,
              radius: 26,
              color: color,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 44),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppSkeletonBlock(height: 24, radius: 12),
                      SizedBox(height: 14),
                      FractionallySizedBox(
                        widthFactor: 0.68,
                        child: AppSkeletonBlock(height: 24, radius: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            for (var index = 0; index < 4; index++) ...[
              AppSkeletonBlock(height: 68, radius: 18, color: color),
              if (index < 3) const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}
