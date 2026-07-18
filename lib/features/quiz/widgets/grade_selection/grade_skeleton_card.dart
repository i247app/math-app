import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';

class GradeSkeletonCard extends StatelessWidget {
  const GradeSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: AppColors.teal700.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
          const Spacer(),
          Container(
            width: 72,
            height: 15,
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}
