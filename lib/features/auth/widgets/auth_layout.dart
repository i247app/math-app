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
    this.hasScrollableBody = false,
  });

  final VoidCallback onBack;
  final WidgetBuilder bodyBuilder;
  final String? title;
  final Widget? titleWidget;
  final double bodyGap;
  final bool fillRemainingBody;
  final bool hasScrollableBody;

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
            Widget content = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthHeader(
                  onBack: onBack,
                  title: title,
                  titleWidget: titleWidget,
                ),
                SizedBox(height: bodyGap),
                if (fillRemainingBody)
                  Expanded(child: bodyBuilder(context))
                else
                  bodyBuilder(context),
              ],
            );
            if (fillRemainingBody) {
              // Forms may grow when validation text appears. A nested viewport
              // instead needs a bounded height and cannot use intrinsic layout.
              content = hasScrollableBody
                  ? SizedBox(height: constraints.maxHeight, child: content)
                  : IntrinsicHeight(child: content);
            }
            // Auth routes do not resize their Scaffold for the keyboard. Shrink
            // the scroll viewport while keeping the form's full-height layout.
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const ClampingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _maxWidth,
                      minHeight: fillRemainingBody && !hasScrollableBody
                          ? constraints.maxHeight
                          : _minHeight,
                    ),
                    child: SizedBox(width: double.infinity, child: content),
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
