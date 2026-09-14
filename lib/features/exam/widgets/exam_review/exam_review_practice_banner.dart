import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class ExamReviewPracticeBanner extends StatelessWidget {
  const ExamReviewPracticeBanner({
    super.key,
    required this.onTap,
    this.focusText,
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final String? focusText;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final normalizedFocus = focusText?.trim();
    final hasFocus = normalizedFocus != null && normalizedFocus.isNotEmpty;
    final radius = BorderRadius.circular(16);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        key: const ValueKey('exam-review-practice-banner'),
        onTap: isLoading ? null : onTap,
        borderRadius: radius,
        child: Ink(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: colors.border.withValues(alpha: 0.65)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFFF1FCFC), Color(0xFFFFE7DC)],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -4,
                bottom: -18,
                width: 156,
                height: 156,
                child: Image.asset(
                  'assets/images/assessment-active-mascot.png',
                  fit: BoxFit.contain,
                  cacheWidth: 420,
                  cacheHeight: 420,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 15, 142, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.getText(AppKeys.examReviewPracticeBannerTitle),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: colors.textPrimary,
                          fontSize: FontSize.normal,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      if (hasFocus) ...[
                        const SizedBox(height: 2),
                        Expanded(
                          child: Text(
                            normalizedFocus,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.andika(
                              color: colors.textPrimary,
                              fontSize: FontSize.small,
                              fontWeight: FontWeight.w700,
                              height: 1.18,
                            ),
                          ),
                        ),
                      ] else
                        const Spacer(),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.coral600,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.coral600.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLoading)
                                SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.onBrand,
                                  ),
                                )
                              else
                                Text(
                                  context.getText(
                                    AppKeys.examReviewPracticeBannerAction,
                                  ),
                                  maxLines: 1,
                                  style: GoogleFonts.andika(
                                    color: colors.onBrand,
                                    fontSize: FontSize.small,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                                ),
                              const SizedBox(width: 5),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: colors.onBrand,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
