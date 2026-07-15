import 'package:flutter/material.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_skeleton_block.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_skeleton_line.dart';

class ParentRoomLoadingContent extends StatelessWidget {
  const ParentRoomLoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          children: const [
            ParentRoomSkeletonBlock(),
            ParentRoomSkeletonBlock(),
          ],
        ),
        const SizedBox(height: 24),
        const ParentRoomSkeletonLine(width: 128),
        const SizedBox(height: 14),
        const ParentRoomSkeletonBlock(height: 104),
        const SizedBox(height: 14),
        const ParentRoomSkeletonBlock(height: 104),
        const SizedBox(height: 14),
        const ParentRoomSkeletonLine(width: 92),
        const SizedBox(height: 14),
        const ParentRoomSkeletonBlock(height: 104),
      ],
    );
  }
}
