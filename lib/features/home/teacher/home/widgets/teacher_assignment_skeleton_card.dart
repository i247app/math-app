import 'package:flutter/material.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_card.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';

class TeacherAssignmentSkeletonCard extends StatelessWidget {
  const TeacherAssignmentSkeletonCard({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonCard(
      scale: scale,
      padding: EdgeInsets.all(18 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonBlock(
            width: 58 * scale,
            height: 42 * scale,
            radius: 12 * scale,
          ),
          const Spacer(),
          AppSkeletonBlock(
            width: 94 * scale,
            height: 18 * scale,
            radius: 8 * scale,
          ),
          SizedBox(height: 8 * scale),
          AppSkeletonBlock(
            width: 126 * scale,
            height: 13 * scale,
            radius: 8 * scale,
          ),
        ],
      ),
    );
  }
}
