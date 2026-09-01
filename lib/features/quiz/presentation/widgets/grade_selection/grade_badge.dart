import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/quiz/presentation/widgets/grade_selection/grade_option.dart';

class GradeBadge extends StatelessWidget {
  const GradeBadge({super.key, required this.option, required this.isSelected});

  final GradeOption option;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    const size = 35.0;

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
              size: 19,
            )
          : Text(
              option.number!,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.teal700,
                fontSize: FontSize.medium,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0,
              ),
            ),
    );
  }
}
