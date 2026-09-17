import 'package:flutter/material.dart';

import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_question_badge.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_question_font_size.dart';

class ExamReviewQuestionCard extends StatelessWidget {
  const ExamReviewQuestionCard({super.key, required this.question});

  final ExamQuestion question;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      constraints: const BoxConstraints(minHeight: 146),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: ExamReviewQuestionBadge(
              number: question.questionNumber,
              color: AppColors.aquaMist,
              textColor: AppColors.teal600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.questionName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: examReviewQuestionFontSize(question.questionName),
              fontWeight: FontWeight.w900,
              height: 1.08,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
