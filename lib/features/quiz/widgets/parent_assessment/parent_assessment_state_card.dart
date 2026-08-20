import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';

class ParentAssessmentStateCard extends StatelessWidget {
  const ParentAssessmentStateCard({
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Icon(icon, color: colors.brandStrong, size: 32),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textStyles.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w900,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: context.textStyles.bodySmall?.copyWith(
                color: colors.textMuted,
                fontSize: FontSize.caption,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
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
