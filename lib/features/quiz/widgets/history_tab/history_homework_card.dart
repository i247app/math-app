part of '../../history_tab.dart';

class _HistoryHomeworkCard extends StatelessWidget {
  const _HistoryHomeworkCard({
    required this.exercise,
    required this.scale,
    required this.onTap,
  });

  final ClassroomExercise exercise;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scorePercent = _historyHomeworkScorePercentage(exercise);
    final dateParts = _historyDatePartsFromIso(
      historyHomeworkDateText(exercise),
    );
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
            border: Border.all(color: AppColors.borderWarm, width: 1.3 * scale),
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
              if (scorePercent != null)
                _HistoryScoreBadge(
                  percentage: scorePercent,
                  colors: _historyScoreColors(context, scorePercent),
                  scale: scale,
                )
              else
                _HistorySubmittedBadge(scale: scale),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HistoryMetaRow(parts: dateParts, scale: scale),
                    SizedBox(height: 7 * scale),
                    Text(
                      _historyHomeworkTitle(context, exercise),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textInk,
                        fontSize: FontSize.normal * scale,
                        fontWeight: FontWeight.w800,
                        height: 1.28,
                        letterSpacing: 0,
                      ),
                    ),
                    if (_historyHomeworkShortText(context, exercise)
                        case final shortText?) ...[
                      SizedBox(height: 4 * scale),
                      Text(
                        shortText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textWarmMuted,
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
                color: AppColors.navyDark,
                size: 26 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
