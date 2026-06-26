part of '../../../home_screen.dart';

class _ParentAssessmentTabCard extends StatelessWidget {
  const _ParentAssessmentTabCard({
    required this.entry,
    required this.scale,
    required this.onTap,
  });

  final _ParentAssessmentEntry entry;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = entry.quiz.grading?.scorePercentage;
    final scoreStyle = _parentAssessmentScoreStyle(context, percent);
    final dateParts = _parentAssessmentDateParts(entry.quiz.createDt);
    final shortText = _parentQuizShortText(entry.quiz);
    final radius = BorderRadius.circular(24 * scale);

    return Material(
      color: Colors.white,
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
            color: Colors.white,
            borderRadius: radius,
            border: Border.all(
              color: const Color(0xFFE3DDDF),
              width: 1.3 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ParentAssessmentScoreBadge(
                percentage: percent,
                color: scoreStyle.color,
                label: scoreStyle.label,
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
                        _ParentAssessmentMetaItem(
                          icon: Icons.calendar_month_outlined,
                          label: dateParts.dt,
                          scale: scale,
                        ),
                        _ParentAssessmentMetaItem(
                          icon: Icons.schedule_rounded,
                          label: dateParts.tm,
                          scale: scale,
                        ),
                      ],
                    ),
                    SizedBox(height: 7 * scale),
                    Text(
                      _parentQuizTitle(context, entry.quiz),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF17252B),
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
                        style: const TextStyle(
                          color: Color(0xFF5D4A54),
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
                color: const Color(0xFF083B78),
                size: 26 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
