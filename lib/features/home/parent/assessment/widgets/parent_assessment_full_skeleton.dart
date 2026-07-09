import 'package:flutter/material.dart';
import 'package:numi/features/home/shared/widgets/home_skeleton_block.dart';
import 'package:numi/features/home/shared/widgets/home_skeleton_line.dart';
import 'package:numi/features/home/parent/assessment/widgets/parent_assessment_list_skeleton.dart';
import 'package:numi/features/home/parent/assessment/widgets/parent_assessment_skeleton_pulse.dart';

class ParentAssessmentFullSkeleton extends StatelessWidget {
  const ParentAssessmentFullSkeleton({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ParentAssessmentSkeletonPulse(
      builder: (context, color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSkeletonBlock(
            height: 111 * scale,
            radius: 10 * scale,
            color: color,
          ),
          SizedBox(height: 13 * scale),
          HomeSkeletonBlock(
            height: 44 * scale,
            radius: 22 * scale,
            color: color,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18 * scale),
              child: Align(
                alignment: Alignment.centerLeft,
                child: HomeSkeletonLine(
                  width: 150 * scale,
                  height: 10 * scale,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(height: 20 * scale),
          HomeSkeletonLine(
            width: 178 * scale,
            height: 18 * scale,
            color: color,
          ),
          SizedBox(height: 8 * scale),
          HomeSkeletonBlock(
            height: 124 * scale,
            radius: 10 * scale,
            color: color,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                20 * scale,
                16 * scale,
                14 * scale,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var index = 0; index < 5; index++) ...[
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: HomeSkeletonBlock(
                          width: 28 * scale,
                          height: (34 + index * 13) * scale,
                          radius: 14 * scale,
                          color: color,
                        ),
                      ),
                    ),
                    if (index < 4) SizedBox(width: 10 * scale),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16 * scale),
          ParentAssessmentListSkeleton(scale: scale),
        ],
      ),
    );
  }
}