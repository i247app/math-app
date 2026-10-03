import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/models/exam.dart';

class ExamReviewWeakTopicsCard extends StatelessWidget {
  const ExamReviewWeakTopicsCard({
    super.key,
    required this.topics,
    this.aiReviewShort,
    this.onOpenAiReview,
  });

  final List<ExamPracticeTopic> topics;
  final String? aiReviewShort;
  final VoidCallback? onOpenAiReview;

  @override
  Widget build(BuildContext context) {
    final topicText = topics
        .map((topic) => topic.topic.trim())
        .where((topic) => topic.isNotEmpty)
        .join(', ');
    final aiText = aiReviewShort?.trim() ?? '';
    final reviewText = aiText.isNotEmpty ? aiText : topicText;
    if (reviewText.isEmpty) return const SizedBox.shrink();
    final colors = context.themeColors;

    return Container(
      key: const ValueKey('exam-review-weak-topics-card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.getText(AppKeys.examReviewWeakTopicsTitle),
                  style: GoogleFonts.andika(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  reviewText,
                  style: GoogleFonts.andika(
                    fontSize: 14,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (onOpenAiReview != null) ...[
            const SizedBox(width: 8),
            SizedBox.square(
              dimension: 48,
              child: IconButton(
                key: const ValueKey('exam-review-open-text'),
                onPressed: onOpenAiReview,
                tooltip: context.getText(AppKeys.examReviewWeakTopicsTitle),
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textMuted,
                  size: 32,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
