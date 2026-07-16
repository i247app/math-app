import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/app_back_button.dart';
import 'package:numi/shared/layouts/page_header.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.onBack,
    required this.bodyBuilder,
    this.title,
    this.titleWidget,
    this.compactBodyGap = 34,
    this.regularBodyGap = 46,
    this.fillRemainingBody = false,
    this.mascotShape = BoxShape.circle,
    this.mascotShadowAlpha = 0.08,
    this.mascotShadowBlur = 24,
    this.mascotShadowOffset = const Offset(0, 12),
  });

  final VoidCallback onBack;
  final Widget Function(BuildContext context, bool compact) bodyBuilder;
  final String? title;
  final Widget? titleWidget;
  final double compactBodyGap;
  final double regularBodyGap;
  final bool fillRemainingBody;
  final BoxShape mascotShape;
  final double mascotShadowAlpha;
  final double mascotShadowBlur;
  final Offset mascotShadowOffset;

  static const _maxWidth = 430.0;
  static const _compactBreakpoint = 690.0;
  static const _backIconAsset = 'assets/images/pin_figma_back.svg';
  static const _mascotAsset = 'assets/images/numi-mascot.png';
  static const _compactMetrics = (
    minHeight: 610.0,
    topGap: 54.0,
    mascotSize: 156.0,
    titleGap: 2.0,
  );
  static const _regularMetrics = (
    minHeight: 690.0,
    topGap: 74.0,
    mascotSize: 184.0,
    titleGap: 4.0,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      // The owning auth flow provides the Scaffold and deliberately keeps the
      // layout fixed while the keyboard is visible. Avoid another Scaffold here
      // so keyboard inset changes do not have two layout owners to reconcile.
      child: Material(
        color: colors.pageBackground,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                MediaQuery.sizeOf(context).height < _compactBreakpoint;
            final metrics = compact ? _compactMetrics : _regularMetrics;
            final bodyGap = compact ? compactBodyGap : regularBodyGap;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: _maxWidth,
                    minHeight: metrics.minHeight,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: constraints.maxHeight,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: PageHeader(
                            scale: 1,
                            backgroundColor: Colors.transparent,
                            actionWidth: 44,
                            horizontalPadding: 20,
                            verticalPadding: 8,
                            leading: AppBackButton(
                              iconAsset: _backIconAsset,
                              onPressed: onBack,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: metrics.topGap),
                            RepaintBoundary(
                              child: Center(
                                child: _AuthMascot(
                                  size: metrics.mascotSize,
                                  shape: mascotShape,
                                  shadowAlpha: mascotShadowAlpha,
                                  shadowBlur: mascotShadowBlur,
                                  shadowOffset: mascotShadowOffset,
                                ),
                              ),
                            ),
                            if (titleWidget != null || title != null) ...[
                              SizedBox(height: metrics.titleGap),
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
                      ],
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
    required this.size,
    required this.shape,
    required this.shadowAlpha,
    required this.shadowBlur,
    required this.shadowOffset,
  });

  final double size;
  final BoxShape shape;
  final double shadowAlpha;
  final double shadowBlur;
  final Offset shadowOffset;

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
          width: size * 0.88 * (759 / 698),
          height: size * 0.88,
          child: Image.asset(AuthLayout._mascotAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
