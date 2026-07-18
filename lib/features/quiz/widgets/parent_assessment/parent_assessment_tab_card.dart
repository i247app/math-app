import 'package:numi/features/quiz/helpers/parent_assessment_quiz_helpers.dart';
import 'package:flutter/material.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/quiz/helpers/parent_assessment_helpers.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_score_badge.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_meta_item.dart';

class AssessmentResultListItemCard extends StatelessWidget {
  const AssessmentResultListItemCard({
    super.key,
    required this.quiz,
    required this.onTap,
  });

  final GeneratedQuiz quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final percent = quiz.grading?.scorePercentage;
    final scoreStyle = parentAssessmentScoreStyle(context, percent);
    final dateParts = parentAssessmentDateParts(quiz.createDt);
    final shortText = homeQuizShortText(quiz);
    final radius = BorderRadius.circular(24);

    return Material(
      color: colors.elevatedSurface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          constraints: const BoxConstraints(minHeight: 116),
          padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: radius,
            border: Border.all(color: colors.border, width: 1.3),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ParentAssessmentScoreBadge(
                percentage: percent,
                color: scoreStyle.color,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 14,
                        runSpacing: 5,
                        children: [
                          ParentAssessmentMetaItem(
                            icon: Icons.calendar_month_outlined,
                            label: dateParts.dt,
                          ),
                          ParentAssessmentMetaItem(
                            icon: Icons.schedule_rounded,
                            label: dateParts.tm,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          homeQuizTitle(context, quiz),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: FontSize.normal,
                            fontWeight: FontWeight.w800,
                            height: 1.28,
                          ),
                        ),
                      ),
                      if (shortText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            shortText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: FontSize.small,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.brandStrong,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
