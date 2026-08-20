import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors.brandStrong, size: 48),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: context.textStyles.titleLarge?.copyWith(
                color: colors.textPrimary,
                fontSize: FontSize.large,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: colors.textMuted,
                fontSize: FontSize.small,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: TextButton(
              onPressed: onTap,
              child: Text(context.getText(AppKeys.retry)),
            ),
          ),
        ],
      ),
    );
  }
}
