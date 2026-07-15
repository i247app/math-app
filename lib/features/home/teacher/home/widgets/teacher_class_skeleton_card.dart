import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_card.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';

class TeacherClassSkeletonCard extends StatelessWidget {
  const TeacherClassSkeletonCard({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonCard(
      scale: scale,
      padding: EdgeInsets.all(12 * scale),
      child: Column(
        children: [
          AppSkeletonBlock(
            width: 84 * scale,
            height: 56 * scale,
            radius: 16 * scale,
          ),
          SizedBox(height: 8 * scale),
          AppSkeletonBlock(
            width: 72 * scale,
            height: 16 * scale,
            radius: 8 * scale,
          ),
          SizedBox(height: 8 * scale),
          Divider(color: const Color(0x1AC4C6D2), height: 4 * scale),
          AppSkeletonBlock(
            width: 88 * scale,
            height: 12 * scale,
            radius: 8 * scale,
          ),
          SizedBox(height: 5 * scale),
          AppSkeletonBlock(
            width: 69 * scale,
            height: 14 * scale,
            radius: 5 * scale,
            color: AppColors.teal520.withValues(alpha: 0.20),
          ),
        ],
      ),
    );
  }
}
