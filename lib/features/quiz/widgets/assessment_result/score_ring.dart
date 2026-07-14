import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/quiz/helpers/score_number.dart';
import 'package:numi/shared/widgets/score_progress_ring.dart';

class AssessmentScoreRing extends StatelessWidget {
  const AssessmentScoreRing({
    super.key,
    required this.scale,
    required this.scoreText,
    required this.accentColor,
  });

  final double scale;
  final String scoreText;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final slashIndex = scoreText.indexOf('/');
    final scoreValue = slashIndex == -1
        ? scoreText
        : scoreText.substring(0, slashIndex);
    final scoreTotal = slashIndex == -1
        ? '/10'
        : scoreText.substring(slashIndex);

    return Center(
      child: SizedBox(
        width: 192 * scale,
        height: 168 * scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: 192 * scale,
                height: 160 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F0F7).withValues(alpha: 0.42),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE6F0F7).withValues(alpha: 0.70),
                      blurRadius: 32 * scale,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
            ScoreProgressRing(
              progress: (scoreNumber(scoreValue) / 10).clamp(0, 1).toDouble(),
              color: accentColor,
              size: 150 * scale,
              strokeWidth: 9 * scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: scoreValue,
                          style: GoogleFonts.andika(
                            color: accentColor,
                            fontSize: 48 * scale,
                            fontWeight: FontWeight.w800,
                            height: 40 / 48,
                            letterSpacing: -0.9 * scale,
                          ),
                        ),
                        TextSpan(
                          text: scoreTotal,
                          style: GoogleFonts.andika(
                            color: Colors.black,
                            fontSize: 36 * scale,
                            fontWeight: FontWeight.w800,
                            height: 40 / 36,
                            letterSpacing: -0.9 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Text(
                    context.getText(AppKeys.scoreUpper),
                    style: GoogleFonts.andika(
                      color: AppColors.textSubtle,
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w800,
                      height: 15 / 10,
                      letterSpacing: 1 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
