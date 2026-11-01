import 'package:flutter/material.dart';

import 'package:numi/features/home/widgets/parent/home_content_skeleton.dart';

/// Matches Home while the parent or student profile is being resolved.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key, required this.bottomPadding, this.homeHeader});

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
            padding: EdgeInsets.fromLTRB(14, 14, 14, bottomPadding + 18),
            child: const HomeContentSkeleton(),
          ),
        ],
      ),
    );
  }
}
