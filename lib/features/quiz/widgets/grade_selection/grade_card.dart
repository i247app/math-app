import 'package:flutter/material.dart';

import 'package:numi/features/quiz/widgets/grade_selection/grade_badge.dart';
import 'package:numi/features/quiz/widgets/grade_selection/grade_option.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class GradeCard extends StatelessWidget {
  const GradeCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onSelected,
  });

  final GradeOption option;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: option.label,
      selected: isSelected,
      button: true,
      enabled: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(28),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 17),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isSelected ? AppColors.teal700 : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.teal700.withValues(alpha: 0.16)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelected ? 16 : 10,
                  offset: Offset(0, isSelected ? 7 : 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradeBadge(option: option, isSelected: isSelected),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    option.label,
                    maxLines: 1,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: FontSize.medium,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
