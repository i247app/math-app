import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/teacher/teacher_skeleton_carousel.dart';
import 'package:numi/features/home/widgets/teacher/teacher_assignment_skeleton_card.dart';

class TeacherAssignmentsLoadingPanel extends StatelessWidget {
  const TeacherAssignmentsLoadingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return TeacherSkeletonCarousel(
      itemWidth: 178,
      itemHeight: 164,
      itemCount: 2,
      builder: (context) => const TeacherAssignmentSkeletonCard(),
    );
  }
}
