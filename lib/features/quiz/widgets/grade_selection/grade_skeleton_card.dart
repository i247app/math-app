import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';

class GradeSkeletonCard extends StatelessWidget {
  const GradeSkeletonCard({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        20 * scale,
        20 * scale,
        17 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(28 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35 * scale,
            height: 35 * scale,
            decoration: BoxDecoration(
              color: AppColors.teal700.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
          const Spacer(),
          Container(
            width: 72 * scale,
            height: 15 * scale,
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
