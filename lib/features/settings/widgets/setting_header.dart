import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/layouts/page_header.dart';

class SettingHeader extends StatelessWidget {
  const SettingHeader({
    super.key,
    required this.title,
    required this.canGoBack,
    required this.onBack,
    required this.backgroundColor,
    required this.topInset,
  });

  final String title;
  final bool canGoBack;
  final VoidCallback onBack;
  final Color backgroundColor;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return PageHeader(
      title: title,
      topInset: topInset,
      backgroundColor: backgroundColor,
      actionWidth: 40,
      horizontalPadding: 18,
      verticalPadding: 6,
      leading: canGoBack
          ? _SettingHeaderButton(
              icon: Icons.arrow_back_rounded,
              outlined: false,
              onTap: onBack,
            )
          : null,
    );
  }
}

class _SettingHeaderButton extends StatelessWidget {
  const _SettingHeaderButton({
    required this.icon,
    required this.outlined,
    required this.onTap,
  });

  final IconData icon;
  final bool outlined;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onTap();
      },
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, color: colors.brandStrong, size: 22),
      ),
    );
  }
}
