import 'package:flutter/material.dart';

import 'package:numi/features/quiz/domain/models/quiz.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/quiz/presentation/widgets/quiz_review/quiz_review_centered_text.dart';

class QuizReviewAnswerTile extends StatelessWidget {
  const QuizReviewAnswerTile({
    super.key,
    required this.answer,
    required this.selectedLabel,
    required this.correctLabel,
    required this.showCorrectAnswer,
    this.onTap,
  });

  final QuizAnswer answer;
  final String? selectedLabel;
  final String? correctLabel;
  final bool showCorrectAnswer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = answer.label.trim().toUpperCase();
    final isSelected = selectedLabel == label;
    final isCorrect = correctLabel == label;
    final hasSelection = selectedLabel != null;
    final isWrongSelected = hasSelection && isSelected && !isCorrect;
    final isRevealedCorrect = isCorrect && (isSelected || showCorrectAnswer);
    final borderColor = isWrongSelected
        ? AppColors.red
        : isRevealedCorrect
        ? AppColors.teal600
        : AppColors.borderSoft;
    final background = isWrongSelected
        ? AppColors.redSoft
        : isRevealedCorrect
        ? AppColors.tealLightSurface
        : Colors.white;
    final foreground = isWrongSelected || isRevealedCorrect
        ? (isWrongSelected ? AppColors.red : AppColors.teal600)
        : AppColors.textInk;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 59),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected ? 1.8 : 1),
          ),
          child: Row(
            spacing: 14,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isWrongSelected
                      ? AppColors.red
                      : isRevealedCorrect
                      ? AppColors.tealAccent
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isWrongSelected || isRevealedCorrect
                        ? Colors.transparent
                        : const Color(0xFF9BB0B3),
                  ),
                ),
                child: QuizReviewCenteredText(
                  label,
                  color: isWrongSelected || isRevealedCorrect
                      ? Colors.white
                      : AppColors.textInk,
                  fontSize: FontSize.xs,
                  fontWeight: FontWeight.w900,
                  verticalOffset: 1.2,
                ),
              ),
              Expanded(
                child: Text(
                  answer.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: FontSize.large,
                    fontWeight: isWrongSelected || isRevealedCorrect
                        ? FontWeight.w900
                        : FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (isWrongSelected || isRevealedCorrect)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isWrongSelected ? AppColors.red : AppColors.teal600,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isWrongSelected ? Icons.close_rounded : Icons.check_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
