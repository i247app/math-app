import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/home/shared/widgets/home_inline_error_banner.dart';

class ParentHomeErrorCard extends StatelessWidget {
  const ParentHomeErrorCard({
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
      retryLabel: context.getText(AppKeys.parentTryAgain),
      backgroundColor: const Color(0xFFFFF5F1),
      textColor: const Color(0xFF8A4433),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 14,
      maxLines: 2,
    );
  }
}
