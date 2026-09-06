import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_card.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';

class TeacherClassSkeletonCard extends StatelessWidget {
  const TeacherClassSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const AppSkeletonBlock(width: 84, height: 56, radius: 16),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: AppSkeletonBlock(width: 72, height: 16, radius: 8),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Divider(color: Color(0x1AC4C6D2), height: 4),
          ),
          const AppSkeletonBlock(width: 88, height: 12, radius: 8),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: AppSkeletonBlock(
              width: 69,
              height: 14,
              radius: 5,
              color: AppColors.teal520.withValues(alpha: 0.20),
            ),
          ),
        ],
      ),
    );
  }
}
