import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/quiz/widgets/assessment_result/ai_review_text.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class AssessmentAiReviewCard extends StatelessWidget {
  const AssessmentAiReviewCard({
    super.key,
    required this.scale,
    required this.reviewText,
  });

  final double scale;
  final String reviewText;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 161 * scale,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(32 * scale),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 2 * scale,
            offset: Offset(0, 1 * scale),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45 * scale,
            top: -45 * scale,
            child: Container(
              width: 96 * scale,
              height: 96 * scale,
              decoration: const BoxDecoration(
                color: AppColors.aiAccentSurface,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56 * scale,
                height: 56 * scale,
                padding: EdgeInsets.all(2 * scale),
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.mascotBorder,
                    width: 2 * scale,
                  ),
                ),
                child: ClipOval(
                  child: Transform.scale(
                    scale: 1.18,
                    child: Image.asset(
                      'assets/images/onboarding_splash_mascot.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 2 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              context.getText(AppKeys.numiAiReview),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.andika(
                                color: colors.textPrimary,
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w800,
                                height: 20 / 14,
                                letterSpacing: -0.1 * scale,
                              ),
                            ),
                          ),
                          SizedBox(width: 4 * scale),
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: colors.brandStrong,
                            size: 15 * scale,
                          ),
                        ],
                      ),
                      SizedBox(height: 4 * scale),
                      AssessmentAiReviewText(
                        scale: scale,
                        reviewText: reviewText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
