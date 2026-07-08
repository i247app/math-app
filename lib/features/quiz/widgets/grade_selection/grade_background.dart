import 'package:flutter/material.dart';

import 'package:numi_flutter/core/theme/app_colors.dart';

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
            AppColors.gradeBackground,
            Color(0xFFD8EBD8),
            AppColors.gradeBackground,
          ],
          stops: [0, 0.80, 1],
        ),
      ),
    );
  }
}
