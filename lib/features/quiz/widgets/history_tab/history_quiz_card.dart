part of 'package:numi/features/quiz/presentation/tabs/history_tab.dart';

class _HistoryQuizCard extends StatelessWidget {
  const _HistoryQuizCard({
    required this.quiz,
    required this.scale,
    required this.onTap,
  });

  final GeneratedQuiz quiz;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final grading = quiz.grading;
    final percent = grading?.scorePercentage;
    final scoreColors = _historyScoreColors(context, percent);
    final dateParts = _historyDatePartsFromIso(quiz.createDt);

    final radius = BorderRadius.circular(24 * scale);
    final colors = context.themeColors;

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
                color: colors.shadow,
                blurRadius: 12 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (percent != null)
                _HistoryScoreBadge(
                  percentage: percent,
                  colors: scoreColors,
                  scale: scale,
                )
              else
                _HistoryIncompleteBadge(scale: scale),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HistoryMetaRow(parts: dateParts, scale: scale),
                    SizedBox(height: 7 * scale),
                    Text(
                      _historyQuizTitle(context, quiz),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: FontSize.normal * scale,
                        fontWeight: FontWeight.w800,
                        height: 1.28,
                        letterSpacing: 0,
                      ),
                    ),
                    if (_historyQuizShortText(quiz) case final shortText?) ...[
                      SizedBox(height: 4 * scale),
                      Text(
                        shortText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: FontSize.small * scale,
                          fontWeight: FontWeight.w500,
                          height: 1.22,
                          letterSpacing: 0,
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
