import 'package:flutter/material.dart';

import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

class DashboardSessionSkeleton extends StatelessWidget {
  const DashboardSessionSkeleton({
    super.key,
    required this.topPadding,
    required this.bottomPadding,
  });

  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonLoader(
      builder: (context, color) => SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, topPadding + 18, 20, bottomPadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSkeletonBlock(height: 104, radius: 24, color: color),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppSkeletonBlock(
                    width: 156,
                    height: 18,
                    radius: 9,
                    color: color,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 142,
                  child: Row(
                    children: [
                      Expanded(
                        child: AppSkeletonBlock(
                          height: 142,
                          radius: 20,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppSkeletonBlock(
                          height: 142,
                          radius: 20,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppSkeletonBlock(
                    width: 190,
                    height: 18,
                    radius: 9,
                    color: color,
                  ),
                ),
                const SizedBox(height: 14),
                AppSkeletonBlock(height: 118, radius: 20, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
