import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/exam/widgets/shared/exam_wave_loader.dart';

class AssessmentTestAgainLoader extends StatelessWidget {
  const AssessmentTestAgainLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ExamWaveLoader(
      message: context.getText(AppKeys.generatingNewExam),
      letterStyle: GoogleFonts.andika(
        color: isDark ? colors.brandStrong : AppColors.teal700,
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1,
        letterSpacing: 3,
      ),
      messageStyle: GoogleFonts.andika(
        color: isDark ? colors.textSecondary : AppColors.textSubtle,
        fontSize: FontSize.normal,
        fontWeight: FontWeight.w800,
        height: 1.35,
        letterSpacing: 0,
      ),
      messageHorizontalPadding: 0,
    );
  }
}
