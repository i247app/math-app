import 'package:flutter/material.dart';

import 'package:numi_flutter/features/quiz/widgets/assessment/assessment_style.dart';
import 'package:numi_flutter/features/quiz/widgets/shared/quiz_wave_loader.dart';

class AssessmentGeneratingLoader extends StatelessWidget {
  const AssessmentGeneratingLoader({
    super.key,
    required this.scale,
    this.message,
  });

  final double scale;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return QuizWaveLoader(
      scale: scale,
      message: message,
      letterStyle: TextStyle(
        color: AssessmentStyle.teal,
        fontSize: 40 * scale,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: 3 * scale,
      ),
      messageStyle: TextStyle(
        color: AssessmentStyle.muted,
        fontSize: 16 * scale,
        fontWeight: FontWeight.w800,
        height: 1.35,
        letterSpacing: 0,
      ),
    );
  }
}
