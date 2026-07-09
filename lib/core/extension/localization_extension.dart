import 'package:flutter/material.dart';

import '../localization/app_keys.dart';
import '../localization/lingo_scope.dart';

extension LingoExtension on BuildContext {
  String getText(String key) {
    return LingoScope.of(this).lookup(key);
  }

  String readText(String key) {
    return LingoScope.read(this).lookup(key);
  }

  String formatText(String key, Map<String, Object?> values) {
    return LingoScope.of(this).format(key, values);
  }

  String readFormatText(String key, Map<String, Object?> values) {
    return LingoScope.read(this).format(key, values);
  }

  Future<void> showErrorDialog(String message) {
    return _showMessageDialog(message, isError: true);
  }

  Future<void> showInfoDialog(String message) {
    return _showMessageDialog(message);
  }

  Future<void> _showMessageDialog(String message, {bool isError = false}) {
    return showDialog<void>(
      context: this,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final color = isError
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface;

        return AlertDialog(
          icon: Icon(
            isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            color: color,
          ),
          content: Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(dialogContext.getText(AppKeys.close)),
            ),
          ],
        );
      },
    );
  }
}
