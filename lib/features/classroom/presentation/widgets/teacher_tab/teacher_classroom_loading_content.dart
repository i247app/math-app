import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_card.dart';
import 'package:numi/features/classroom/presentation/widgets/teacher_tab/teacher_classroom_skeleton_card.dart';

class TeacherClassroomLoadingContent extends StatelessWidget {
  const TeacherClassroomLoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: AppSkeletonBlock(
            width: 90,
            height: 36,
            radius: 12,
            color: AppColors.coralTeacher.withValues(alpha: 0.18),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: AppSkeletonCard(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  AppSkeletonBlock(width: 24, height: 24, radius: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: AppSkeletonBlock(
                        width: double.infinity,
                        height: 14,
                        radius: 7,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: AppSkeletonBlock(width: 24, height: 24, radius: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            spacing: 16,
            children: List.generate(
              3,
              (_) => const TeacherClassroomSkeletonCard(),
            ),
          ),
        ),
      ],
    );
  }
}
