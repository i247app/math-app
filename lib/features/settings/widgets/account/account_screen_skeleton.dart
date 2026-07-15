import 'package:flutter/material.dart';

import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_shimmer.dart';

class AccountScreenSkeleton extends StatefulWidget {
  const AccountScreenSkeleton({super.key, required this.scale});

  final double scale;

  @override
  State<AccountScreenSkeleton> createState() => _AccountScreenSkeletonState();
}

class _AccountScreenSkeletonState extends State<AccountScreenSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
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
      shimmerWidthFactor: 1.2,
      highlightColor: Colors.white.withValues(alpha: 0.78),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: AppSkeletonBlock(
              width: 36 * scale,
              height: 36 * scale,
              radius: 10 * scale,
              color: const Color(0xFFE8EEF0),
            ),
          ),
          SizedBox(height: 10 * scale),
          AppSkeletonBlock(
            width: 126 * scale,
            height: 126 * scale,
            radius: 63 * scale,
            color: const Color(0xFFE8EEF0),
          ),
          SizedBox(height: 24 * scale),
          for (var index = 0; index < 3; index++) ...[
            AppSkeletonBlock(
              height: 68 * scale,
              radius: 16 * scale,
              color: const Color(0xFFE8EEF0),
            ),
            if (index < 2) SizedBox(height: 20 * scale),
          ],
        ],
      ),
    );
  }
}
