import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';

class GradeSkeletonCard extends StatelessWidget {
  const GradeSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.teal700.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}
