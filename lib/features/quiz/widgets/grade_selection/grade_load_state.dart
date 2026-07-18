import 'package:flutter/material.dart';

import 'package:numi/features/quiz/widgets/grade_selection/grade_skeleton_card.dart';

class GradeLoadState extends StatelessWidget {
  const GradeLoadState({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        return const GradeSkeletonCard();
      },
    );
  }
}
