import 'package:flutter/material.dart';
import 'package:numi/features/home/shared/widgets/home_skeleton_card.dart';
import 'package:numi/features/home/shared/widgets/home_skeleton_block.dart';

class TeacherAssignmentSkeletonCard extends StatelessWidget {
  const TeacherAssignmentSkeletonCard({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return HomeSkeletonCard(
      scale: scale,
      padding: EdgeInsets.all(18 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSkeletonBlock(
            width: 58 * scale,
            height: 42 * scale,
            radius: 12 * scale,
          ),
          const Spacer(),
          HomeSkeletonBlock(
            width: 94 * scale,
            height: 18 * scale,
            radius: 8 * scale,
          ),
          SizedBox(height: 8 * scale),
          HomeSkeletonBlock(
            width: 126 * scale,
            height: 13 * scale,
            radius: 8 * scale,
          ),
        ],
      ),
    );
  }
}
