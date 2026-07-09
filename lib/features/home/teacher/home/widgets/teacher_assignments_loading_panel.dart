import 'package:flutter/material.dart';
import 'package:numi_flutter/features/home/teacher/home/widgets/teacher_skeleton_carousel.dart';
import 'package:numi_flutter/features/home/teacher/home/widgets/teacher_assignment_skeleton_card.dart';

class TeacherAssignmentsLoadingPanel extends StatelessWidget {
  const TeacherAssignmentsLoadingPanel({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return TeacherSkeletonCarousel(
      scale: scale,
      itemWidth: 178 * scale,
      itemHeight: 164 * scale,
      itemCount: 2,
      builder: (context) => TeacherAssignmentSkeletonCard(scale: scale),
    );
  }
}
