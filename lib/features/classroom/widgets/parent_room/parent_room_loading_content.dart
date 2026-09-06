import 'package:flutter/material.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_line.dart';

class ParentRoomLoadingContent extends StatelessWidget {
  const ParentRoomLoadingContent({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 14,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.55,
          padding: EdgeInsets.zero,
          children: [
            AppSkeletonBlock(radius: 16, color: color),
            AppSkeletonBlock(radius: 16, color: color),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: AppSkeletonLine(width: 128, height: 22, color: color),
        ),
        AppSkeletonBlock(height: 104, radius: 16, color: color),
        AppSkeletonBlock(height: 104, radius: 16, color: color),
        AppSkeletonLine(width: 92, height: 22, color: color),
        AppSkeletonBlock(height: 104, radius: 16, color: color),
      ],
    );
  }
}
