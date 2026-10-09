import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/exam_math_text.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_question_badge.dart';

class ExamReviewQuestionCard extends StatelessWidget {
  const ExamReviewQuestionCard({super.key, required this.question});

  final ExamQuestion question;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final questionStyle = TextStyle(
      color: colors.textPrimary,
      fontSize: _questionFontSize(question.questionName),
      fontWeight: FontWeight.w900,
      height: 1.08,
      letterSpacing: 0,
    );
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
          if (question.isFraction)
            ExamMathText(
              question.questionName,
              textAlign: TextAlign.center,
              style: questionStyle,
            )
          else
            Text(
              question.questionName,
              textAlign: TextAlign.center,
              style: questionStyle,
            ),
        ],
      ),
    );
  }
}

double _questionFontSize(String text) {
  final length = text.trim().length;
  if (length <= 16) {
    return 40;
  }
  if (length <= 28) {
    return 31;
  }
  return 24;
}
