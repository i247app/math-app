import 'package:flutter/material.dart';

import 'package:numi/features/quiz/helpers/score_number.dart';
import 'package:numi/shared/widgets/score_progress_ring.dart';

class AssessmentScoreRing extends StatelessWidget {
  const AssessmentScoreRing({
    super.key,
    required this.scoreText,
    required this.accentColor,
  });
  final String scoreText;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final slashIndex = scoreText.indexOf('/');
    final scoreValue = slashIndex == -1
        ? scoreText
        : scoreText.substring(0, slashIndex);
    return ScoreDisplayRing(
      scoreText: scoreText,
      progress: (scoreNumber(scoreValue) / 10).clamp(0, 1).toDouble(),
      ringColor: accentColor,
      scoreColor: accentColor,
    );
  }
}
