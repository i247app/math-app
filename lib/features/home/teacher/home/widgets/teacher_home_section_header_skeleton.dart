import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_shimmer.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';

class TeacherAppSectionHeaderSkeleton extends StatefulWidget {
  const TeacherAppSectionHeaderSkeleton({super.key, required this.scale});

  final double scale;

  @override
  State<TeacherAppSectionHeaderSkeleton> createState() =>
      _TeacherAppSectionHeaderSkeletonState();
}

class _TeacherAppSectionHeaderSkeletonState
    extends State<TeacherAppSectionHeaderSkeleton>
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
    return AppSkeletonShimmer(
      controller: _controller,
      child: Row(
        children: [
          AppSkeletonBlock(
            width: 42 * scale,
            height: 42 * scale,
            radius: 14 * scale,
            color: AppColors.teal520.withValues(alpha: 0.16),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: AppSkeletonBlock(
              width: double.infinity,
              height: 22 * scale,
              radius: 10 * scale,
            ),
          ),
          SizedBox(width: 16 * scale),
          AppSkeletonBlock(
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
