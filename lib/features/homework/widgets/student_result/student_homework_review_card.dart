import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class StudentHomeworkReviewCard extends StatelessWidget {
  const StudentHomeworkReviewCard({super.key, required this.reviewText});
  final String reviewText;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 161,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -45,
            child: Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.aiAccentSurface,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.mascotBorder, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/onboarding-splash-mascot.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Row(
                        spacing: 4,
                        children: [
                          Flexible(
                            child: Text(
                              context.getText(AppKeys.numiAiReview),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.andika(
                                color: colors.textPrimary,
                                fontSize: FontSize.small,
                                fontWeight: FontWeight.w800,
                                height: 20 / 14,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: colors.brandStrong,
                            size: 15,
                          ),
                        ],
                      ),
                      Text(
                        '"$reviewText"',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: colors.textSecondary,
                          fontSize: FontSize.xxs,
                          fontWeight: FontWeight.w400,
                          height: 19.5 / 12,
                          letterSpacing: -0.1,
                        ),
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
