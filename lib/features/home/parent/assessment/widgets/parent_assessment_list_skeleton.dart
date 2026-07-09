import 'package:flutter/material.dart';
import 'package:numi_flutter/features/home/shared/widgets/home_skeleton_block.dart';
import 'package:numi_flutter/features/home/shared/widgets/home_skeleton_line.dart';
import 'package:numi_flutter/features/home/parent/assessment/widgets/parent_assessment_skeleton_pulse.dart';

class ParentAssessmentListSkeleton extends StatelessWidget {
  const ParentAssessmentListSkeleton({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ParentAssessmentSkeletonPulse(
      builder: (context, color) => Column(
        children: [
          for (var index = 0; index < 3; index++) ...[
            HomeSkeletonBlock(
              height: 116 * scale,
              radius: 24 * scale,
              color: color,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16 * scale,
                  14 * scale,
                  16 * scale,
                  14 * scale,
                ),
                child: Row(
                  children: [
                    HomeSkeletonBlock(
                      width: 54 * scale,
                      height: 54 * scale,
                      radius: 27 * scale,
                      color: color,
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeSkeletonLine(
                            width: 136 * scale,
                            height: 8 * scale,
                            color: color,
                          ),
                          SizedBox(height: 7 * scale),
                          HomeSkeletonLine(
                            width: 176 * scale,
                            height: 13 * scale,
                            color: color,
                          ),
                          SizedBox(height: 6 * scale),
                          HomeSkeletonLine(
                            width: 112 * scale,
                            height: 8 * scale,
                            color: color,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (index < 2) SizedBox(height: 14 * scale),
          ],
        ],
      ),
    );
  }
}