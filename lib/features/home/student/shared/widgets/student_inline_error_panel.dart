import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/home_inline_error_banner.dart';

class StudentInlineErrorPanel extends StatelessWidget {
  const StudentInlineErrorPanel({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return HomeInlineErrorBanner(
      message: message,
      onRetry: onRetry,
      retryLabel: context.getText(AppKeys.studentRetry),
      backgroundColor: Colors.white,
      textColor: const Color(0xFF444650),
      padding: const EdgeInsets.all(13),
      borderRadius: 16,
      borderColor: const Color(0xFFC4C6D2).withValues(alpha: 0.5),
      textHeight: 1.25,
    );
  }
}
