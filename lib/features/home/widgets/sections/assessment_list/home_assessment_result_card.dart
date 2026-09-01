import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_shadows.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/quiz/application/read_models/parent_assessment_display_read_model.dart';
import 'package:numi/features/quiz/application/read_models/parent_assessment_read_model.dart';
import 'package:numi/features/quiz/domain/models/quiz.dart';
import 'package:numi/shared/widgets/score_progress_ring.dart';

class HomeAssessmentResultCard extends StatelessWidget {
  const HomeAssessmentResultCard({
    super.key,
    required this.quiz,
    required this.onTap,
    this.useCardShadow = false,
  });

  final GeneratedQuiz quiz;
  final VoidCallback onTap;
  final bool useCardShadow;

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
            boxShadow: useCardShadow
                ? AppShadows.card(colors)
                : [
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ScoreBadge(percentage: percent, color: scoreStyle.color),
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
                          _MetaItem(
                            icon: Icons.calendar_month_outlined,
                            label: dateParts.dt,
                          ),
                          _MetaItem(
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

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.percentage, required this.color});

  final int? percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: ScoreProgressRing(
        progress: percentage == null ? 0 : percentage!.clamp(0, 100) / 100,
        color: color,
        size: 48,
        strokeWidth: 5,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            percentage == null ? '--' : '${(percentage! / 10).round()}',
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: FontSize.xxxl,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        Icon(icon, color: const Color(0xFF5D4A54), size: 18),
        Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            color: Color(0xFF5D4A54),
            fontSize: FontSize.caption,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
