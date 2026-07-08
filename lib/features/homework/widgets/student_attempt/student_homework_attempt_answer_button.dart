import 'package:flutter/material.dart';

import 'package:numi_flutter/features/homework/widgets/student_attempt/student_homework_attempt_helpers.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';

class StudentHomeworkAttemptAnswerButton extends StatelessWidget {
  const StudentHomeworkAttemptAnswerButton({
    super.key,
    required this.answer,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final StudentHomeworkAttemptAnswer answer;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppColors.teal700
        : Colors.black.withValues(alpha: 0);
    final textColor = selected ? AppColors.teal700 : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(32 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32 * scale),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32 * scale),
            border: Border.all(color: borderColor, width: 2 * scale),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF73F1E7).withValues(alpha: 0.20),
                      spreadRadius: 4 * scale,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 6 * scale,
                      offset: Offset(0, 4 * scale),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2 * scale,
                      offset: Offset(0, 1 * scale),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Text(
                answer.label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Text(
                  answer.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18 * scale,
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
