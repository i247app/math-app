import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_shadows.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/data/exam_image_cache.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/exam_math_text.dart';

import 'assessment_question_speaker.dart';
import 'assessment_text_normalizer.dart';

/// A text prompt followed by a two-column choice of pictures.
class AssessmentImageChoiceCard extends StatelessWidget {
  const AssessmentImageChoiceCard({
    super.key,
    required this.question,
    required this.selectedOptionIds,
    required this.onSelected,
    this.feedbackCorrect,
    this.onReadQuestion,
  });

  final ExamQuestion question;
  final Set<String> selectedOptionIds;
  final ValueChanged<ExamAnswer> onSelected;
  final bool? feedbackCorrect;
  final VoidCallback? onReadQuestion;

  static bool supports(ExamQuestion question) =>
      question.questionKind == 'SINGLE_CHOICE' &&
      question.questionText.trim().isNotEmpty &&
      !RegExp(r'^\d+$').hasMatch(question.questionText.trim()) &&
      (question.questionImageUrl?.trim().isEmpty ?? true) &&
      question.options.length >= 2 &&
      question.options.every(
        (option) =>
            option.text.trim().isEmpty &&
            (option.imageUrl?.trim().isNotEmpty ?? false),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final prompt = normalizeAssessmentText(question.questionText);
    final style = TextStyle(
      color: colors.brandStrong,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.3,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              if (onReadQuestion != null) ...[
                AssessmentQuestionSpeaker(onPressed: onReadQuestion),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: question.isFraction
                    ? ExamMathText(prompt, style: style)
                    : Text(prompt, style: style),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          padding: const EdgeInsets.all(4),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: question.options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final option = question.options[index];
            final label = String.fromCharCode(65 + index);
            final selected = selectedOptionIds.contains(option.id);
            final accent = selected
                ? switch (feedbackCorrect) {
                    true => colors.success,
                    false => colors.error,
                    null => colors.brandStrong,
                  }
                : colors.brandStrong;
            return Semantics(
              key: ValueKey('image-choice-option-${option.id}'),
              label: label,
              button: true,
              selected: selected,
              child: Material(
                color: colors.elevatedSurface,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: () => onSelected(option),
                  borderRadius: BorderRadius.circular(24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? accent.withValues(alpha: 0.08) : null,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: selected
                            ? accent
                            : colors.border.withValues(alpha: 0.25),
                        width: 2,
                      ),
                      boxShadow: AppShadows.card(colors),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image(
                            image: ExamImageCache.provider(
                              option.imageUrl!.trim(),
                            ),
                            fit: BoxFit.contain,
                            excludeFromSemantics: true,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.broken_image_outlined,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: 0.1),
                          ),
                          child: FittedBox(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: accent,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
