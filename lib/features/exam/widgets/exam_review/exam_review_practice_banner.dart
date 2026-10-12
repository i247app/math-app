import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_typography.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';

class ExamReviewPracticeBanner extends StatelessWidget {
  const ExamReviewPracticeBanner({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final radius = BorderRadius.circular(16);

    return LayoutBuilder(
      builder: (context, constraints) {
        final mascotWidth = constraints.maxWidth * 0.44;
        return Semantics(
          button: true,
          enabled: !isLoading,
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: const ValueKey('exam-review-practice-banner'),
              onTap: isLoading ? null : onTap,
              borderRadius: radius,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.warningSurface, colors.errorSurface],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -8,
                      top: 8,
                      bottom: -10,
                      width: mascotWidth,
                      child: Image.asset(
                        'assets/images/review-practice-mascot.png',
                        fit: constraints.maxWidth >= 330
                            ? BoxFit.cover
                            : BoxFit.contain,
                        alignment: Alignment.bottomRight,
                        cacheWidth: 600,
                        filterQuality: FilterQuality.high,
                        excludeFromSemantics: true,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, mascotWidth + 2, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.getText(
                              AppKeys.examReviewPracticeBannerTitle,
                            ),
                            style:
                                (context.textStyles.bodyLarge ??
                                        const TextStyle())
                                    .copyWith(
                                      color: colors.textPrimary,
                                      fontSize: FontSize.large,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            key: const ValueKey('exam-review-practice-action'),
                            width:
                                (constraints.maxWidth - mascotWidth - 18) * 0.9,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                colors: [colors.accentStrong, colors.accent],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.accent.withValues(alpha: 0.65),
                                  offset: const Offset(0, 5),
                                ),
                                BoxShadow(
                                  color: colors.accent.withValues(alpha: 0.19),
                                  offset: const Offset(0, 7),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: SizedBox(
                              height: 28,
                              width: double.infinity,
                              child: isLoading
                                  ? Center(
                                      child: SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colors.onAccent,
                                        ),
                                      ),
                                    )
                                  : FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        context.getText(
                                          AppKeys
                                              .examReviewPracticeBannerAction,
                                        ),
                                        style:
                                            (context.textStyles.bodyLarge ??
                                                    const TextStyle())
                                                .copyWith(
                                                  color: colors.onAccent,
                                                  fontSize: FontSize.normal,
                                                  fontWeight: FontWeight.w800,
                                                  height: 1.2,
                                                ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
