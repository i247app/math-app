import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';

Future<bool> showUnsavedChangesExitDialog(BuildContext context) {
  return showExitConfirmationDialog(
    context,
    titleKey: AppKeys.unsavedChangesExitTitle,
    messageKey: AppKeys.unsavedChangesExitMessage,
    stayActionKey: AppKeys.continueUpper,
    exitActionKey: AppKeys.discardChangesUpper,
  );
}

Future<bool> showExitConfirmationDialog(
  BuildContext context, {
  required String titleKey,
  required String messageKey,
  required String stayActionKey,
  required String exitActionKey,
}) async {
  final colors = context.themeColors;
  final shouldExit = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: colors.elevatedSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          context.getText(titleKey),
          style: context.textStyles.titleLarge?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        content: Text(
          context.getText(messageKey),
          style: context.textStyles.bodyMedium?.copyWith(
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
              context.getText(stayActionKey),
              style: context.textStyles.labelLarge?.copyWith(
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
              context.getText(exitActionKey),
              style: context.textStyles.labelLarge?.copyWith(
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
