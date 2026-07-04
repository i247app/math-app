import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/quiz/widgets/assessment_result/assessment_result_style.dart';
import 'package:numi_flutter/features/quiz/widgets/shared/quiz_wave_loader.dart';

class AssessmentTestAgainLoader extends StatelessWidget {
  const AssessmentTestAgainLoader({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return QuizWaveLoader(
      scale: scale,
      message: context.getText(AppKeys.generatingNewQuiz),
      letterStyle: GoogleFonts.andika(
        color: AssessmentResultStyle.teal,
        fontSize: 40 * scale,
        fontWeight: FontWeight.w800,
        height: 1,
        letterSpacing: 3 * scale,
      ),
      messageStyle: GoogleFonts.andika(
        color: AssessmentResultStyle.muted,
        fontSize: 16 * scale,
        fontWeight: FontWeight.w800,
        height: 1.35,
        letterSpacing: 0,
      ),
      messageHorizontalPadding: 0,
    );
  }
}
