import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

abstract final class AppShadows {
  static List<BoxShadow> card(AppThemeColors colors) => <BoxShadow>[
    BoxShadow(
      color: colors.shadow.withValues(alpha: 0.18),
      blurRadius: 14,
      offset: const Offset(0, 5),
    ),
  ];
}
