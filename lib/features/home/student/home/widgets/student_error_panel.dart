import 'package:flutter/material.dart';
import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/home/student/home/widgets/student_message_panel.dart';

class StudentErrorPanel extends StatelessWidget {
  const StudentErrorPanel({
    super.key,
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  final double scale;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return StudentMessagePanel(
      scale: scale,
      icon: Icons.wifi_off_rounded,
      title: message,
      message: context.getText(AppKeys.retry),
      actionLabel: context.getText(AppKeys.retryUpper),
      onAction: onRetry,
    );
  }
}
