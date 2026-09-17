import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/widgets/app_state_panel.dart';

class ParentRoomStateCard extends StatelessWidget {
  const ParentRoomStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return AppStatePanel(
      title: title,
      message: message,
      actionLabel: context.getText(AppKeys.retry),
      onAction: onTap,
      padding: const EdgeInsets.all(28),
      borderRadius: 24,
      visual: Icon(icon, color: colors.brandStrong, size: 48),
      titleStyle: context.textStyles.titleLarge?.copyWith(
        color: colors.textPrimary,
        fontSize: FontSize.large,
        fontWeight: FontWeight.w900,
      ),
      messageStyle: context.textStyles.bodyMedium?.copyWith(
        color: colors.textMuted,
        fontSize: FontSize.small,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
    );
  }
}
