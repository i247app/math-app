import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/models/exam.dart';

class ExamReviewWeakTopicsCard extends StatelessWidget {
  const ExamReviewWeakTopicsCard({super.key, required this.topics});

  final List<ExamPracticeTopic> topics;

  @override
  Widget build(BuildContext context) {
    final topicText = topics
        .map((topic) => topic.topic.trim())
        .where((topic) => topic.isNotEmpty)
        .join(', ');
    if (topicText.isEmpty) return const SizedBox.shrink();
    final colors = context.themeColors;

    return Container(
      key: const ValueKey('exam-review-weak-topics-card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories_outlined,
                color: colors.brandStrong,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.getText(AppKeys.examReviewWeakTopicsTitle),
                  style: GoogleFonts.andika(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            topicText,
            style: GoogleFonts.andika(fontSize: 14, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
