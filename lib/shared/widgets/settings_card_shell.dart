import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_radius.dart';
import 'package:numi/core/theme/app_spacing.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

/// Common surface and spacing for settings rows, with an optional row action.
class SettingsCardShell extends StatelessWidget {
  const SettingsCardShell({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final radius = BorderRadius.circular(AppRadius.r16);
    final content = Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
    return Material(
      color: colors.elevatedSurface,
      elevation: 0,
      borderRadius: radius,
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, borderRadius: radius, child: content),
    );
  }
}
