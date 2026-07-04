import 'package:flutter/material.dart';

import 'package:numi_flutter/features/quiz/widgets/grade_selection/grade_selection_style.dart';

class GradeBackground extends StatelessWidget {
  const GradeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GradeSelectionStyle.mint,
            Color(0xFFD8EBD8),
            GradeSelectionStyle.mint,
          ],
          stops: [0, 0.80, 1],
        ),
      ),
    );
  }
}
