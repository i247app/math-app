import 'package:flutter/material.dart';

import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class AssessmentAnswerButton extends StatelessWidget {
  const AssessmentAnswerButton({
    super.key,
    required this.answer,
    required this.selected,
    required this.onTap,
  });

  final QuizAnswer answer;
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                answer.content,
                style: TextStyle(
                  color: textColor,
                  fontSize: FontSize.displaySmall,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 8 : 0,
                height: selected ? 12 : 0,
                padding: const EdgeInsets.only(top: 4),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.brandStrong,
                    shape: BoxShape.circle,
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
