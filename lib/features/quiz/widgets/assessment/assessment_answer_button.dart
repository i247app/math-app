import 'package:flutter/material.dart';

import 'package:numi/features/quiz/data/dto/quiz_models.dart';
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
    final isNumeric = isNumericAssessmentContent(answer.content);
    final textColor = selected && isNumeric
        ? colors.brandStrong
        : colors.textPrimary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F8F8) : colors.elevatedSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: selected ? 5 : 2,
                offset: Offset(0, selected ? 3 : 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.brandStrong
                        : const Color(0xFFEFFFFC),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    answer.label,
                    style: TextStyle(
                      color: selected ? colors.onBrand : colors.brandStrong,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    answer.content,
                    textAlign: TextAlign.left,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: _fontSizeFor(answer.content),
                      fontWeight: isNumeric ? FontWeight.w900 : FontWeight.w500,
                      height: 1.1,
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

  double _fontSizeFor(String value) {
    final length = value.trim().length;
    if (length <= 5) return FontSize.displaySmall;
    if (length <= 12) return 30;
    if (length <= 24) return 24;
    if (length <= 48) return 20;
    return 18;
  }
}

bool isNumericAssessmentContent(String value) {
  final normalized = value.trim();
  return normalized.isNotEmpty &&
      RegExp(r'\d').hasMatch(normalized) &&
      RegExp(r'^[0-9\s+×xX*/÷:()=?.,%\-−]+$').hasMatch(normalized);
}
