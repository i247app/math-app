import 'package:flutter/material.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:numi_flutter/features/home/shared/widgets/home_skeleton_card.dart';
import 'package:numi_flutter/features/home/shared/widgets/home_skeleton_block.dart';

class TeacherClassSkeletonCard extends StatelessWidget {
  const TeacherClassSkeletonCard({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return HomeSkeletonCard(
      scale: scale,
      padding: EdgeInsets.all(12 * scale),
      child: Column(
        children: [
          HomeSkeletonBlock(
            width: 84 * scale,
            height: 56 * scale,
            radius: 16 * scale,
          ),
          SizedBox(height: 8 * scale),
          HomeSkeletonBlock(
            width: 72 * scale,
            height: 16 * scale,
            radius: 8 * scale,
          ),
          SizedBox(height: 8 * scale),
          Divider(color: const Color(0x1AC4C6D2), height: 4 * scale),
          HomeSkeletonBlock(
            width: 88 * scale,
            height: 12 * scale,
            radius: 8 * scale,
          ),
          SizedBox(height: 5 * scale),
          HomeSkeletonBlock(
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
