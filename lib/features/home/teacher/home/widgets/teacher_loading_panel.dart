import 'package:flutter/material.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_skeleton_carousel.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_class_skeleton_card.dart';

class TeacherLoadingPanel extends StatelessWidget {
  const TeacherLoadingPanel({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return TeacherSkeletonCarousel(
      scale: scale,
      itemWidth: 166 * scale,
      itemHeight: 176 * scale,
      itemCount: 2,
      builder: (context) => TeacherClassSkeletonCard(scale: scale),
    );
  }
}
