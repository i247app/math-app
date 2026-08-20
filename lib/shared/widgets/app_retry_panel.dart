import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';

class AppRetryPanel extends StatelessWidget {
  const AppRetryPanel({
    super.key,
    required this.message,
    required this.onRetry,
    this.scale = 1,
    this.padding = 20,
    this.borderRadius = 24,
    this.messageFontSize = FontSize.caption,
    this.messageFontWeight = FontWeight.w600,
    this.filledAction = false,
  });

  final String message;
  final VoidCallback onRetry;
  final double scale;
  final double padding;
  final double borderRadius;
  final double messageFontSize;
  final FontWeight messageFontWeight;
  final bool filledAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final retryLabel = Text(context.getText(AppKeys.retry));
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding * scale),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(borderRadius * scale),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textStyles.bodySmall?.copyWith(
              color: filledAction ? colors.textPrimary : colors.textSecondary,
              fontSize: messageFontSize * scale,
              fontWeight: messageFontWeight,
            ),
          ),
          SizedBox(height: 12 * scale),
          if (filledAction)
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: colors.brandStrong,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
              ),
              child: retryLabel,
            )
          else
            TextButton(onPressed: onRetry, child: retryLabel),
        ],
      ),
    );
  }
}
