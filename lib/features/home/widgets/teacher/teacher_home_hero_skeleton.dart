import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_card.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';

class TeacherHomeHeroSkeleton extends StatelessWidget {
  const TeacherHomeHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: AppSkeletonCard(
        padding: const EdgeInsets.fromLTRB(14, 14, 18, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  AppSkeletonBlock(
                    width: 148,
                    height: 20,
                    radius: 8,
                    color: AppColors.teal520.withValues(alpha: 0.18),
                  ),
                  const AppSkeletonBlock(width: 218, height: 15, radius: 8),
                ],
              ),
            ),
            AppSkeletonBlock(
              width: 64,
              height: 64,
              radius: 20,
              color: AppColors.teal400.withValues(alpha: 0.22),
            ),
          ],
        ),
      ),
    );
  }
}
