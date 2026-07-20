import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/home/student/home/widgets/student_message_panel.dart';

class StudentErrorPanel extends StatelessWidget {
  const StudentErrorPanel({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return StudentMessagePanel(
      icon: Icons.wifi_off_rounded,
      title: message,
      message: context.getText(AppKeys.retry),
      actionLabel: context.getText(AppKeys.retryUpper),
      onAction: onRetry,
    );
  }
}
