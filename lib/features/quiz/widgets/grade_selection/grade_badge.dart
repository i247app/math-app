import 'package:flutter/material.dart';

import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:numi_flutter/features/quiz/widgets/grade_selection/grade_option.dart';
import 'package:numi_flutter/features/quiz/widgets/grade_selection/grade_selection_style.dart';

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
        color: isSelected ? GradeSelectionStyle.teal : AppColors.aquaMist,
        shape: BoxShape.circle,
      ),
      child: option.number == null
          ? Icon(
              Icons.school_rounded,
              color: isSelected ? Colors.white : GradeSelectionStyle.teal,
              size: 19 * scale,
            )
          : Text(
              option.number!,
              style: TextStyle(
                color: isSelected ? Colors.white : GradeSelectionStyle.teal,
                fontSize: 17 * scale,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0,
              ),
            ),
    );
  }
}
