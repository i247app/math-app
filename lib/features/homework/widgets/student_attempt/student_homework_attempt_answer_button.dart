import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/homework/widgets/student_attempt/student_homework_attempt_helpers.dart';

class StudentHomeworkAttemptAnswerButton extends StatelessWidget {
  const StudentHomeworkAttemptAnswerButton({
    super.key,
    required this.answer,
    required this.selected,
    required this.onTap,
  });

  final StudentHomeworkAttemptAnswer answer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final borderColor = selected
        ? colors.brandStrong
        : Colors.black.withValues(alpha: 0);
    final textColor = selected ? colors.brandStrong : colors.textPrimary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF73F1E7).withValues(alpha: 0.20),
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            spacing: 10,
            children: [
              Text(
                answer.label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              Expanded(
                child: Text(
                  answer.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
