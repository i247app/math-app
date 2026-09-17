import 'package:flutter/material.dart';

import 'package:numi/features/home/widgets/parent/parent_child_overview_skeleton.dart';
import 'package:numi/features/home/widgets/sections/learning_streak/learning_streak_skeleton.dart';

/// One layout while the parent profile and Home data are being resolved.
class ParentHomeSkeleton extends StatelessWidget {
  const ParentHomeSkeleton({
    super.key,
    required this.bottomPadding,
    this.homeHeader,
  });

  final double bottomPadding;
  final Widget? homeHeader;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?homeHeader,
          Padding(
            padding: EdgeInsets.fromLTRB(14, 10, 14, bottomPadding + 18),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LearningStreakSkeleton(),
                SizedBox(height: 12),
                ParentChildOverviewSkeleton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
