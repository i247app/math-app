import 'package:flutter/material.dart';

import 'package:numi/features/quiz/widgets/grade_selection/grade_badge.dart';
import 'package:numi/features/quiz/widgets/grade_selection/grade_option.dart';
import 'package:numi/core/theme/app_colors.dart';

class GradeCard extends StatelessWidget {
  const GradeCard({
    super.key,
    required this.option,
    required this.scale,
    required this.isSelected,
    required this.onSelected,
  });

  final GradeOption option;
  final double scale;
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
        borderRadius: BorderRadius.circular(28 * scale),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(28 * scale),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.fromLTRB(
              20 * scale,
              20 * scale,
              20 * scale,
              17 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28 * scale),
              border: Border.all(
                color: isSelected ? AppColors.teal700 : Colors.transparent,
                width: 2 * scale,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.teal700.withValues(alpha: 0.16)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelected ? 16 * scale : 10 * scale,
                  offset: Offset(0, isSelected ? 7 * scale : 4 * scale),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradeBadge(
                  option: option,
                  scale: scale,
                  isSelected: isSelected,
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    option.label,
                    maxLines: 1,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17 * scale,
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
