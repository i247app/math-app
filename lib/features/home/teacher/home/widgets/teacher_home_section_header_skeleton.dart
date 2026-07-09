import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/home/shared/widgets/home_skeleton_shimmer.dart';
import 'package:numi/features/home/shared/widgets/home_skeleton_block.dart';

class TeacherHomeSectionHeaderSkeleton extends StatefulWidget {
  const TeacherHomeSectionHeaderSkeleton({super.key, required this.scale});

  final double scale;

  @override
  State<TeacherHomeSectionHeaderSkeleton> createState() =>
      _TeacherHomeSectionHeaderSkeletonState();
}

class _TeacherHomeSectionHeaderSkeletonState
    extends State<TeacherHomeSectionHeaderSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    return HomeSkeletonShimmer(
      controller: _controller,
      child: Row(
        children: [
          HomeSkeletonBlock(
            width: 42 * scale,
            height: 42 * scale,
            radius: 14 * scale,
            color: AppColors.teal520.withValues(alpha: 0.16),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: HomeSkeletonBlock(
              width: double.infinity,
              height: 22 * scale,
              radius: 10 * scale,
            ),
          ),
          SizedBox(width: 16 * scale),
          HomeSkeletonBlock(
            width: 82 * scale,
            height: 22 * scale,
            radius: 11 * scale,
            color: AppColors.teal520.withValues(alpha: 0.14),
          ),
        ],
      ),
    );
  }
}
