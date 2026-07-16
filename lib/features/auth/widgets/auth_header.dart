import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/widgets/app_back_button.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.onBack,
    required this.mascotShape,
    required this.mascotShadowAlpha,
    required this.mascotShadowBlur,
    required this.mascotShadowOffset,
    this.title,
    this.titleWidget,
  });

  final VoidCallback onBack;
  final String? title;
  final Widget? titleWidget;
  final BoxShape mascotShape;
  final double mascotShadowAlpha;
  final double mascotShadowBlur;
  final Offset mascotShadowOffset;

  static const _backIconAsset = 'assets/images/pin_figma_back.svg';
  static const _mascotAsset = 'assets/images/numi-mascot.png';

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Stack(
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
            const SizedBox(height: 74),
            RepaintBoundary(
              child: Center(
                child: _AuthMascot(
                  size: 184,
                  shape: mascotShape,
                  shadowAlpha: mascotShadowAlpha,
                  shadowBlur: mascotShadowBlur,
                  shadowOffset: mascotShadowOffset,
                ),
              ),
            ),
            if (titleWidget != null || title != null) ...[
              const SizedBox(height: 4),
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
          ],
        ),
      ],
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
          child: Image.asset(AuthHeader._mascotAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
