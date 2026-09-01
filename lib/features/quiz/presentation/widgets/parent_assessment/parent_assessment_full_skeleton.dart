import 'package:flutter/material.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_line.dart';
import 'package:numi/features/quiz/presentation/widgets/parent_assessment/parent_assessment_list_skeleton.dart';
import 'package:numi/features/quiz/presentation/widgets/parent_assessment/parent_assessment_skeleton_pulse.dart';

class ParentAssessmentFullSkeleton extends StatelessWidget {
  const ParentAssessmentFullSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ParentAssessmentSkeletonPulse(
      builder: (context, color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: AppSkeletonBlock(height: 111, radius: 10, color: color),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: AppSkeletonBlock(
              height: 44,
              radius: 22,
              color: color,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppSkeletonLine(width: 150, height: 10, color: color),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppSkeletonLine(width: 178, height: 18, color: color),
          ),
          AppSkeletonBlock(
            height: 124,
            radius: 10,
            color: color,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 10,
                children: List.generate(
                  5,
                  (index) => Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AppSkeletonBlock(
                        width: 28,
                        height: (34 + index * 13),
                        radius: 14,
                        color: color,
                      ),
                    ),
                  ),
                  growable: false,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: ParentAssessmentListSkeleton(),
          ),
        ],
      ),
    );
  }
}
