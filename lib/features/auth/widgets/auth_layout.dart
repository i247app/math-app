import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/widgets/auth_header.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.onBack,
    required this.bodyBuilder,
    this.title,
    this.titleWidget,
    this.bodyGap = 46,
    this.fillRemainingBody = false,
    this.mascotShape = BoxShape.circle,
    this.mascotShadowAlpha = 0.08,
    this.mascotShadowBlur = 24,
    this.mascotShadowOffset = const Offset(0, 12),
  });

  final VoidCallback onBack;
  final WidgetBuilder bodyBuilder;
  final String? title;
  final Widget? titleWidget;
  final double bodyGap;
  final bool fillRemainingBody;
  final BoxShape mascotShape;
  final double mascotShadowAlpha;
  final double mascotShadowBlur;
  final Offset mascotShadowOffset;

  static const _maxWidth = 430.0;
  static const _minHeight = 690.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Material(
        color: colors.pageBackground,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _maxWidth,
                    minHeight: _minHeight,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: constraints.maxHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthHeader(
                          onBack: onBack,
                          title: title,
                          titleWidget: titleWidget,
                          mascotShape: mascotShape,
                          mascotShadowAlpha: mascotShadowAlpha,
                          mascotShadowBlur: mascotShadowBlur,
                          mascotShadowOffset: mascotShadowOffset,
                        ),
                        SizedBox(height: bodyGap),
                        if (fillRemainingBody)
                          Expanded(child: bodyBuilder(context))
                        else
                          bodyBuilder(context),
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
