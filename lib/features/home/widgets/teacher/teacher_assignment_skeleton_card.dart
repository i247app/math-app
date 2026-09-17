import 'package:flutter/material.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_card.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';

class TeacherAssignmentSkeletonCard extends StatelessWidget {
  const TeacherAssignmentSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSkeletonCard(
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonBlock(width: 58, height: 42, radius: 12),
          Spacer(),
          AppSkeletonBlock(width: 94, height: 18, radius: 8),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: AppSkeletonBlock(width: 126, height: 13, radius: 8),
          ),
        ],
      ),
    );
  }
}
