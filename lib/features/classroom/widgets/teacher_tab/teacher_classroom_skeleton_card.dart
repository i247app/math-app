import 'package:flutter/material.dart';

import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_card.dart';

class TeacherClassroomSkeletonCard extends StatelessWidget {
  const TeacherClassroomSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSkeletonCard(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonBlock(width: 76, height: 76, radius: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Column(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeletonBlock(width: 128, height: 21, radius: 10.5),
                      AppSkeletonBlock(width: 142, height: 18, radius: 9),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AppSkeletonBlock(width: 132, height: 18, radius: 9),
        ],
      ),
    );
  }
}
