import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_line.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

class LearningStreakSkeleton extends StatelessWidget {
  const LearningStreakSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return AppSkeletonLoader(
      builder: (context, color) => Container(
        padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
        decoration: BoxDecoration(
          color: colors.elevatedSurface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            AppSkeletonLine(width: 104, height: 14, color: color),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var index = 0; index < 7; index++)
                  _LearningStreakDaySkeleton(color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningStreakDaySkeleton extends StatelessWidget {
  const _LearningStreakDaySkeleton({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      children: [
        AppSkeletonLine(width: 20, height: 11, color: color),
        AppSkeletonBlock(width: 31, height: 31, radius: 16, color: color),
      ],
    );
  }
}
