import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/home/widgets/home_inline_error_banner.dart';

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
    final colors = context.themeColors;
    return HomeInlineErrorBanner(
      message: message,
      onRetry: onRetry,
      retryLabel: context.getText(AppKeys.parentTryAgain),
      backgroundColor: colors.errorSurface,
      textColor: colors.error,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 14,
      maxLines: 2,
    );
  }
}
