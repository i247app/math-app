import 'package:flutter/material.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_line.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_skeleton_pulse.dart';

class ParentAssessmentListSkeleton extends StatelessWidget {
  const ParentAssessmentListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ParentAssessmentSkeletonPulse(
      builder: (context, color) => Column(
        spacing: 14,
        children: List.generate(
          3,
          (index) => AppSkeletonBlock(
            height: 116,
            radius: 24,
            color: color,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                spacing: 12,
                children: [
                  AppSkeletonBlock(
                    width: 54,
                    height: 54,
                    radius: 27,
                    color: color,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: AppSkeletonLine(
                            width: 136,
                            height: 8,
                            color: color,
                          ),
                        ),
                        AppSkeletonLine(width: 176, height: 13, color: color),
                        AppSkeletonLine(width: 112, height: 8, color: color),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          growable: false,
        ),
      ),
    );
  }
}
