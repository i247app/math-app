import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class SettingSafeScreen extends StatelessWidget {
  const SettingSafeScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.themeColors.pageBackground,
      child: SafeArea(child: child),
    );
  }
}
