import 'package:flutter/material.dart';

import 'package:numi/features/quiz/widgets/grade_selection/grade_skeleton_card.dart';

class GradeLoadState extends StatelessWidget {
  const GradeLoadState({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12 * scale,
        crossAxisSpacing: 12 * scale,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        return GradeSkeletonCard(scale: scale);
      },
    );
  }
}
