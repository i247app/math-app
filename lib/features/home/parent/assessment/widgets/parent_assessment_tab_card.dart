import 'package:flutter/material.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/home/parent/assessment/helpers/parent_assessment_helpers.dart';
import 'package:numi/features/home/parent/shared/parent_home_helpers.dart';
import 'package:numi/features/home/parent/assessment/widgets/parent_assessment_score_badge.dart';
import 'package:numi/features/home/parent/assessment/widgets/parent_assessment_meta_item.dart';

class AssessmentResultListItemCard extends StatelessWidget {
  const AssessmentResultListItemCard({
    super.key,
    required this.quiz,
    required this.scale,
    required this.onTap,
  });

  final GeneratedQuiz quiz;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final percent = quiz.grading?.scorePercentage;
    final scoreStyle = parentAssessmentScoreStyle(context, percent);
    final dateParts = parentAssessmentDateParts(quiz.createDt);
    final shortText = homeQuizShortText(quiz);
    final radius = BorderRadius.circular(24 * scale);

    return Material(
      color: colors.elevatedSurface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          constraints: BoxConstraints(minHeight: 116 * scale),
          padding: EdgeInsets.fromLTRB(
            16 * scale,
            14 * scale,
            10 * scale,
            14 * scale,
          ),
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: radius,
            border: Border.all(color: colors.border, width: 1.3 * scale),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.25),
                blurRadius: 12 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ParentAssessmentScoreBadge(
                percentage: percent,
                color: scoreStyle.color,
                scale: scale,
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 14 * scale,
                      runSpacing: 5 * scale,
                      children: [
                        ParentAssessmentMetaItem(
                          icon: Icons.calendar_month_outlined,
                          label: dateParts.dt,
                          scale: scale,
                        ),
                        ParentAssessmentMetaItem(
                          icon: Icons.schedule_rounded,
                          label: dateParts.tm,
                          scale: scale,
                        ),
                      ],
                    ),
                    SizedBox(height: 7 * scale),
                    Text(
                      homeQuizTitle(context, quiz),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: FontSize.normal * scale,
                        fontWeight: FontWeight.w800,
                        height: 1.28,
                      ),
                    ),
                    if (shortText != null) ...[
                      SizedBox(height: 4 * scale),
                      Text(
                        shortText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: FontSize.small,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.brandStrong,
                size: 26 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
