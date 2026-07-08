import 'package:flutter/material.dart';

import 'package:numi_flutter/core/theme/app_colors.dart';
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
      leading: Image.asset(
        'assets/images/numi-mascot.png',
        width: 176 * scale,
        height: 150 * scale,
        fit: BoxFit.contain,
      ),
      message: message,
      letterStyle: TextStyle(
        color: AppColors.teal700,
        fontSize: 40 * scale,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: 3 * scale,
      ),
      messageStyle: TextStyle(
        color: AppColors.textSubtle,
        fontSize: 16 * scale,
        fontWeight: FontWeight.w800,
        height: 1.35,
        letterSpacing: 0,
      ),
    );
  }
}
