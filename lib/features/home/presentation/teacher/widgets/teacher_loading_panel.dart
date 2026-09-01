import 'package:flutter/material.dart';
import 'package:numi/features/home/presentation/teacher/widgets/teacher_skeleton_carousel.dart';
import 'package:numi/features/home/presentation/teacher/widgets/teacher_class_skeleton_card.dart';

class TeacherLoadingPanel extends StatelessWidget {
  const TeacherLoadingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return TeacherSkeletonCarousel(
      itemWidth: 166,
      itemHeight: 176,
      itemCount: 2,
      builder: (context) => const TeacherClassSkeletonCard(),
    );
  }
}
