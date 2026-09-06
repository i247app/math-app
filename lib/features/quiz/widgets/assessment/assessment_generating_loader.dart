import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/quiz/widgets/assessment/numi_assessment_mascot_animation.dart';
import 'package:numi/features/quiz/widgets/shared/quiz_wave_loader.dart';

class AssessmentGeneratingLoader extends StatelessWidget {
  const AssessmentGeneratingLoader({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return QuizWaveLoader(
      leading: const NumiAssessmentMascotAnimation(),
      leadingSpacing: 10,
      message: message,
      letterStyle: const TextStyle(
        color: AppColors.teal700,
        fontSize: FontSize.displayExtraLarge,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: 3,
      ),
      messageStyle: const TextStyle(
        color: AppColors.textSubtle,
        fontSize: FontSize.normal,
        fontWeight: FontWeight.w800,
        height: 1.35,
        letterSpacing: 0,
      ),
    );
  }
}
