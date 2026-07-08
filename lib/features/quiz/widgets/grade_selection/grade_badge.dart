import 'package:flutter/material.dart';

import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:numi_flutter/features/quiz/widgets/grade_selection/grade_option.dart';

class GradeBadge extends StatelessWidget {
  const GradeBadge({
    super.key,
    required this.option,
    required this.scale,
    required this.isSelected,
  });

  final GradeOption option;
  final double scale;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final size = 35 * scale;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.teal700 : AppColors.aquaMist,
        shape: BoxShape.circle,
      ),
      child: option.number == null
          ? Icon(
              Icons.school_rounded,
              color: isSelected ? Colors.white : AppColors.teal700,
              size: 19 * scale,
            )
          : Text(
              option.number!,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.teal700,
                fontSize: 17 * scale,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0,
              ),
            ),
    );
  }
}
