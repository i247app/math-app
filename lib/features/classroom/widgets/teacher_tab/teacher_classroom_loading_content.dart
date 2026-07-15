import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_card.dart';
import 'package:numi/features/classroom/widgets/teacher_tab/teacher_classroom_skeleton_card.dart';

class TeacherClassroomLoadingContent extends StatelessWidget {
  const TeacherClassroomLoadingContent({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: AppSkeletonBlock(
            width: 90 * scale,
            height: 36 * scale,
            radius: 12 * scale,
            color: AppColors.coralTeacher.withValues(alpha: 0.18),
          ),
        ),
        SizedBox(height: 16 * scale),
        AppSkeletonCard(
          scale: scale,
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          child: SizedBox(
            height: 48 * scale,
            child: Row(
              children: [
                AppSkeletonBlock(
                  width: 24 * scale,
                  height: 24 * scale,
                  radius: 12 * scale,
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: AppSkeletonBlock(
                    width: double.infinity,
                    height: 14 * scale,
                    radius: 7 * scale,
                  ),
                ),
                SizedBox(width: 16 * scale),
                AppSkeletonBlock(
                  width: 24 * scale,
                  height: 24 * scale,
                  radius: 12 * scale,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24 * scale),
        for (var index = 0; index < 3; index++) ...[
          TeacherClassroomSkeletonCard(scale: scale),
          if (index != 2) SizedBox(height: 16 * scale),
        ],
      ],
    );
  }
}
