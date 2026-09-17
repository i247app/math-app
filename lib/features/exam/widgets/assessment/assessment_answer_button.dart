import 'package:flutter/material.dart';

import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_text_normalizer.dart';

class AssessmentAnswerButton extends StatelessWidget {
  const AssessmentAnswerButton({
    super.key,
    required this.answer,
    required this.selected,
    required this.onTap,
    this.feedbackCorrect,
  });

  final ExamAnswer answer;
  final bool selected;
  final VoidCallback onTap;
  final bool? feedbackCorrect;

  static const double _borderRadius = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final displayContent = normalizeAssessmentText(answer.content);
    final feedbackColor = switch (feedbackCorrect) {
      true => colors.success,
      false => colors.error,
      null => null,
    };
    final borderColor =
        feedbackColor ??
        (selected ? colors.brandStrong : Colors.black.withValues(alpha: 0));
    final isNumeric = isNumericAssessmentContent(displayContent);
    final textColor =
        feedbackColor ??
        (selected && isNumeric ? colors.brandStrong : colors.textPrimary);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(minHeight: isNumeric ? 90 : 76),
          decoration: BoxDecoration(
            color: feedbackCorrect == true
                ? colors.successSurface
                : feedbackCorrect == false
                ? colors.errorSurface
                : selected
                ? const Color(0xFFE8F8F8)
                : colors.elevatedSurface,
            borderRadius: BorderRadius.circular(_borderRadius),
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
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: isNumeric ? 6 : 2,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? feedbackColor ?? colors.brandStrong
                        : const Color(0xFFEFFFFC),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    answer.label,
                    style: TextStyle(
                      color: selected ? colors.onBrand : colors.brandStrong,
                      fontSize: FontSize.normal,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: isNumeric
                      ? FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            displayContent,
                            maxLines: 1,
                            softWrap: false,
                            style: _answerTextStyle(
                              textColor,
                              isNumeric,
                              displayContent,
                            ),
                          ),
                        )
                      : Text(
                          displayContent,
                          textAlign: TextAlign.left,
                          softWrap: true,
                          maxLines: null,
                          overflow: TextOverflow.visible,
                          textWidthBasis: TextWidthBasis.parent,
                          style: _answerTextStyle(
                            textColor,
                            isNumeric,
                            displayContent,
                          ),
                        ),
                ),
                if (feedbackCorrect != null) ...[
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      feedbackCorrect!
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      key: ValueKey<String>(
                        feedbackCorrect!
                            ? 'assessment-answer-feedback-correct'
                            : 'assessment-answer-feedback-incorrect',
                      ),
                      color: feedbackColor,
                      size: 28,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _answerTextStyle(
    Color color,
    bool isNumeric,
    String displayContent,
  ) {
    return TextStyle(
      color: color,
      fontSize: _fontSizeFor(displayContent),
      fontWeight: isNumeric ? FontWeight.w900 : FontWeight.w500,
      height: 1.2,
      letterSpacing: 0,
    );
  }

  double _fontSizeFor(String value) {
    final length = value.trim().length;
    if (!isNumericAssessmentContent(value)) {
      if (length <= 24) return FontSize.xl;
      if (length <= 48) return FontSize.large;
      return FontSize.normal;
    }

    if (length <= 5) return FontSize.displaySmall;
    if (length <= 12) return FontSize.displaySmall;
    if (length <= 24) return FontSize.xxxl;
    if (length <= 48) return FontSize.xl;
    return FontSize.large;
  }
}

bool isNumericAssessmentContent(String value) {
  final normalized = value.trim();
  return normalized.isNotEmpty &&
      RegExp(r'\d').hasMatch(normalized) &&
      RegExp(r'^[0-9\s+×xX*/÷:()=?.,%\-−]+$').hasMatch(normalized);
}
