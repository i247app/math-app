import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/widgets/app_back_button.dart';

class AppScreenAppBar extends StatelessWidget {
  const AppScreenAppBar({
    super.key,
    required this.title,
    required this.scale,
    required this.onBack,
    required this.backIconAsset,
    this.action,
    this.backgroundColor,
  });

  final String title;
  final double scale;
  final VoidCallback onBack;
  final String backIconAsset;
  final Widget? action;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return PageHeader(
      title: title,
      scale: scale,
      topInset: 0,
      backgroundColor: backgroundColor,
      actionWidth: 48,
      horizontalPadding: 12,
      titleFontSize: FontSize.xxxl * scale,
      boxShadow: [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.05),
          blurRadius: 0,
          offset: Offset(0, 4 * scale),
        ),
      ],
      leading: AppBackButton(
        onPressed: onBack,
        iconAsset: backIconAsset,
        size: 40 * scale,
        iconSize: 16 * scale,
      ),
      trailing: action,
    );
  }
}
