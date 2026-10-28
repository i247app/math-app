import 'package:numi/features/exam/widgets/shared/exam_image.dart';
import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/helpers/exam_review_answers.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/exam_math_text.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_answer_list.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_question_badge.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_question_status.dart';

class ExamReviewResultQuestionCard extends StatelessWidget {
  const ExamReviewResultQuestionCard({
    super.key,
    required this.question,
    required this.selectedLabel,
  });

  final ExamQuestion question;
  final String? selectedLabel;

  @override
  Widget build(BuildContext context) {
    final isCorrect = examReviewIsCorrect(question, selectedLabel);
    final colors = context.themeColors;
    final accent = isCorrect ? colors.primaryAction : colors.error;
    final questionStyle = TextStyle(
      color: colors.textPrimary,
      fontSize: FontSize.xxxl,
      fontWeight: FontWeight.w900,
      height: 1.15,
      letterSpacing: 0,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 18,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        ExamReviewQuestionBadge(
                          number: question.questionNumber,
                          color: isCorrect
                              ? colors.successSurface
                              : colors.errorSurface,
                          textColor: isCorrect
                              ? colors.primaryAction
                              : colors.error,
                        ),
                        ExamReviewQuestionStatus(isCorrect: isCorrect),
                      ],
                    ),
                    if (question.isFraction)
                      ExamMathText(question.questionText, style: questionStyle)
                    else
                      Text(question.questionText, style: questionStyle),
                    ExamImage(url: question.questionImageUrl),
                    ExamReviewAnswerList(
                      question: question,
                      selectedLabel: selectedLabel,
                      showCorrectAnswer: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
