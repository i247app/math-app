import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_shimmer.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';

class TeacherAppSectionHeaderSkeleton extends StatefulWidget {
  const TeacherAppSectionHeaderSkeleton({super.key});

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
    return AppSkeletonShimmer(
      controller: _controller,
      child: Row(
        children: [
          AppSkeletonBlock(
            width: 42,
            height: 42,
            radius: 14,
            color: AppColors.teal520.withValues(alpha: 0.16),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 12),
              child: AppSkeletonBlock(
                width: double.infinity,
                height: 22,
                radius: 10,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: AppSkeletonBlock(
              width: 82,
              height: 22,
              radius: 11,
              color: AppColors.teal520.withValues(alpha: 0.14),
            ),
          ),
        ],
      ),
    );
  }
}
