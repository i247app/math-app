import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

Future<bool> showAttemptExitDialog(BuildContext context) async {
  final colors = context.themeColors;
  final shouldExit = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: colors.elevatedSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          context.getText(AppKeys.attemptExitTitle),
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        content: Text(
          context.getText(AppKeys.attemptExitMessage),
          style: TextStyle(
            color: colors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              context.getText(AppKeys.continueUpper),
              style: TextStyle(
                color: colors.brandStrong,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              context.getText(AppKeys.exitUpper),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      );
    },
  );

  return shouldExit ?? false;
}
