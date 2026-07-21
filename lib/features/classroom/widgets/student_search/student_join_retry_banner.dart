import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/shared/widgets/app_inline_retry_banner.dart';

class StudentJoinRetryBanner extends StatelessWidget {
  const StudentJoinRetryBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppInlineRetryBanner(
      message: message,
      onRetry: onRetry,
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      backgroundColor: const Color(0xFFFFF4ED),
      borderRadius: 10,
      borderColor: const Color(0xFFF4C7AE),
      textColor: const Color(0xFF7E2F0E),
      fontSize: FontSize.xxs,
      textHeight: 1.3,
      leading: const Icon(
        Icons.wifi_off_rounded,
        color: Color(0xFFA03A0F),
        size: 20,
      ),
      leadingSpacing: 9,
      actionSpacing: 0,
      retryTooltip: context.getText(AppKeys.studentRetry),
      retryIcon: const Icon(
        Icons.refresh_rounded,
        color: AppColors.tealActive,
        size: 22,
      ),
    );
  }
}
