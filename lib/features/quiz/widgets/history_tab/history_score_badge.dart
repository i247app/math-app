import 'package:flutter/material.dart';

import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/widgets/score_progress_ring.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_score_badge_colors.dart';

class HistoryScoreBadge extends StatelessWidget {
  const HistoryScoreBadge({
    super.key,
    required this.percentage,
    required this.colors,
  });

  final int percentage;
  final HistoryScoreBadgeColors colors;

  @override
  Widget build(BuildContext context) {
    final scoreOutOf10 = (percentage / 10).round();
    return SizedBox(
      width: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 7,
        children: [
          ScoreProgressRing(
            progress: percentage.clamp(0, 100) / 100,
            color: colors.foreground,
            size: 48,
            strokeWidth: 5,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$scoreOutOf10/10',
                maxLines: 1,
                style: TextStyle(
                  color: colors.foreground,
                  fontSize: FontSize.caption,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          Text(
            colors.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.foreground,
              fontSize: FontSize.caption * 0.77,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
