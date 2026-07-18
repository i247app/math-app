import 'package:flutter/material.dart';

import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_shimmer.dart';

class AccountScreenSkeleton extends StatefulWidget {
  const AccountScreenSkeleton({super.key});

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
    return AppSkeletonShimmer(
      controller: _controller,
      shimmerWidthFactor: 1.2,
      highlightColor: Colors.white.withValues(alpha: 0.78),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: AppSkeletonBlock(
              width: 36,
              height: 36,
              radius: 10,
              color: Color(0xFFE8EEF0),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: AppSkeletonBlock(
              width: 126,
              height: 126,
              radius: 63,
              color: Color(0xFFE8EEF0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              spacing: 20,
              children: List.generate(
                3,
                (_) => const AppSkeletonBlock(
                  height: 68,
                  radius: 16,
                  color: Color(0xFFE8EEF0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
