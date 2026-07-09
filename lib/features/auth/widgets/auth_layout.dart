import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/auth_back_button.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.onBack,
    required this.bodyBuilder,
    this.title,
    this.titleWidget,
    this.backLeft = 20,
    this.backTop = 22,
    this.horizontalPadding,
    this.maxWidth = 430,
    this.minCompactHeight = 610,
    this.minRegularHeight = 690,
    this.compactBreakpoint = 690,
    this.compactTopGap = 54,
    this.regularTopGap = 74,
    this.compactMascotSize = 156,
    this.regularMascotSize = 184,
    this.compactTitleGap = 2,
    this.regularTitleGap = 4,
    this.compactBodyGap = 34,
    this.regularBodyGap = 46,
    this.fillRemainingBody = false,
    this.mascotShape = BoxShape.circle,
    this.mascotShadowAlpha = 0.08,
    this.mascotShadowBlur = 24,
    this.mascotShadowOffset = const Offset(0, 12),
    this.backIconAsset = 'assets/images/pin_figma_back.svg',
    this.mascotAsset = 'assets/images/numi-mascot.png',
    this.mascotAspectRatio = 759 / 698,
    this.mascotVisualScale = 0.88,
  });

  final VoidCallback onBack;
  final Widget Function(BuildContext context, bool compact) bodyBuilder;
  final String? title;
  final Widget? titleWidget;
  final double backLeft;
  final double backTop;
  final double? horizontalPadding;
  final double maxWidth;
  final double minCompactHeight;
  final double minRegularHeight;
  final double compactBreakpoint;
  final double compactTopGap;
  final double regularTopGap;
  final double compactMascotSize;
  final double regularMascotSize;
  final double compactTitleGap;
  final double regularTitleGap;
  final double compactBodyGap;
  final double regularBodyGap;
  final bool fillRemainingBody;
  final BoxShape mascotShape;
  final double mascotShadowAlpha;
  final double mascotShadowBlur;
  final Offset mascotShadowOffset;
  final String backIconAsset;
  final String mascotAsset;
  final double mascotAspectRatio;
  final double mascotVisualScale;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: colors.pageBackground,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final media = MediaQuery.of(context);
            final height = media.size.height;
            final compact = height < compactBreakpoint;
            final fallbackPadding = media.size.width < 370 ? 24.0 : 32.0;
            final sidePadding = horizontalPadding ?? fallbackPadding;
            final minHeight = compact ? minCompactHeight : minRegularHeight;
            final layoutHeight = math.max(constraints.maxHeight, minHeight);
            final mascotSize = compact ? compactMascotSize : regularMascotSize;
            final topGap = compact ? compactTopGap : regularTopGap;
            final titleGap = compact ? compactTitleGap : regularTitleGap;
            final bodyGap = compact ? compactBodyGap : regularBodyGap;

            return SizedBox(
              width: double.infinity,
              height: constraints.maxHeight,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const ClampingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: SizedBox(
                      height: layoutHeight,
                      child: Stack(
                        children: [
                          Positioned(
                            left: backLeft,
                            top: backTop,
                            child: AuthBackButton(
                              iconAsset: backIconAsset,
                              onPressed: onBack,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: sidePadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: topGap),
                                Center(
                                  child: _AuthMascot(
                                    asset: mascotAsset,
                                    size: mascotSize,
                                    shape: mascotShape,
                                    shadowAlpha: mascotShadowAlpha,
                                    shadowBlur: mascotShadowBlur,
                                    shadowOffset: mascotShadowOffset,
                                    aspectRatio: mascotAspectRatio,
                                    visualScale: mascotVisualScale,
                                  ),
                                ),
                                if (titleWidget != null || title != null) ...[
                                  SizedBox(height: titleGap),
                                  Center(
                                    child:
                                        titleWidget ??
                                        Text(
                                          title!,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.andika(
                                            color: colors.textPrimary,
                                            fontSize: 36,
                                            fontWeight: FontWeight.w800,
                                            height: 1.05,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                  ),
                                ],
                                SizedBox(height: bodyGap),
                                if (fillRemainingBody)
                                  Expanded(child: bodyBuilder(context, compact))
                                else
                                  bodyBuilder(context, compact),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthMascot extends StatelessWidget {
  const _AuthMascot({
    required this.asset,
    required this.size,
    required this.shape,
    required this.shadowAlpha,
    required this.shadowBlur,
    required this.shadowOffset,
    required this.aspectRatio,
    required this.visualScale,
  });

  final String asset;
  final double size;
  final BoxShape shape;
  final double shadowAlpha;
  final double shadowBlur;
  final Offset shadowOffset;
  final double aspectRatio;
  final double visualScale;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: shadowAlpha),
            blurRadius: shadowBlur,
            offset: shadowOffset,
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: size * visualScale * aspectRatio,
          height: size * visualScale,
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
