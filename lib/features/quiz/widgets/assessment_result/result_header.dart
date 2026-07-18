import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/quiz/widgets/shared/quiz_header_icon_button.dart';

class AssessmentResultHeader extends StatelessWidget {
  const AssessmentResultHeader({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: QuizHeaderIconButton(
              icon: Icons.arrow_back_rounded,
              color: AppColors.teal500,
              size: 40,
              iconSize: 23,
              borderRadius: 12,
              onTap: onBack,
            ),
          ),
          Text(
            context.getText(AppKeys.assessmentResultTitle),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: AppColors.teal500,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 34 / 25,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
