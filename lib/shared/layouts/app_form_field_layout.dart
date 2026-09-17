import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class AppFormFieldLayout extends StatelessWidget {
  const AppFormFieldLayout({
    super.key,
    required this.label,
    required this.child,
    this.scale = 1,
    required this.labelStyle,
    this.trailing,
    this.labelGap = 8,
    this.height = 56,
    this.horizontalPadding = 16,
    this.borderRadius = 14,
    this.borderColor,
    this.borderWidth = 1.6,
  });

  final String label;
  final Widget child;
  final double scale;
  final TextStyle labelStyle;
  final Widget? trailing;
  final double labelGap;
  final double height;
  final double horizontalPadding;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ),
            ?trailing,
          ],
        ),
        SizedBox(height: labelGap * scale),
        Container(
          height: height * scale,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding * scale),
          decoration: BoxDecoration(
            color: colors.inputSurface,
            borderRadius: BorderRadius.circular(borderRadius * scale),
            border: Border.all(
              color: borderColor ?? colors.border,
              width: borderWidth * scale,
            ),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ],
    );
  }
}
