import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_card.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';

class TeacherHomeHeroSkeleton extends StatelessWidget {
  const TeacherHomeHeroSkeleton({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92 * scale,
      child: AppSkeletonCard(
        scale: scale,
        padding: EdgeInsets.fromLTRB(
          14 * scale,
          14 * scale,
          18 * scale,
          14 * scale,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppSkeletonBlock(
                    width: 148 * scale,
                    height: 20 * scale,
                    radius: 8 * scale,
                    color: AppColors.teal520.withValues(alpha: 0.18),
                  ),
                  SizedBox(height: 10 * scale),
                  AppSkeletonBlock(
                    width: 218 * scale,
                    height: 15 * scale,
                    radius: 8 * scale,
                  ),
                ],
              ),
            ),
            AppSkeletonBlock(
              width: 64 * scale,
              height: 64 * scale,
              radius: 20 * scale,
              color: AppColors.teal400.withValues(alpha: 0.22),
            ),
          ],
        ),
      ),
    );
  }
}
