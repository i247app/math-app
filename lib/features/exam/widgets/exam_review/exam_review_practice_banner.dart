import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';

class ExamReviewPracticeBanner extends StatelessWidget {
  const ExamReviewPracticeBanner({
    super.key,
    required this.onTap,
    this.isLoading = false,
    this.aiShortText,
  });

  final VoidCallback onTap;
  final bool isLoading;
  final String? aiShortText;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final subtitle = aiShortText?.trim() ?? '';

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
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFF6EC), Color(0xFFFFDED0)],
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
                            style: GoogleFonts.andika(
                              color: const Color(0xFF254443),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: GoogleFonts.andika(
                                color: const Color(0xFF254443),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Container(
                            key: const ValueKey('exam-review-practice-action'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF9B29), Color(0xFFFF4E28)],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFFD9421E),
                                  offset: Offset(0, 5),
                                ),
                                BoxShadow(
                                  color: Color(0x30FF792B),
                                  offset: Offset(0, 7),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: SizedBox(
                              height: 28,
                              width: double.infinity,
                              child: isLoading
                                  ? const Center(
                                      child: SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
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
                                        style: GoogleFonts.andika(
                                          color: Colors.white,
                                          fontSize: 16,
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
