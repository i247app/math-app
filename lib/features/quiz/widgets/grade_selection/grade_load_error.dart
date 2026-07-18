import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';

class GradeLoadError extends StatelessWidget {
  const GradeLoadError({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        spacing: 12,
        children: [
          const Icon(Icons.school_outlined, color: AppColors.teal700, size: 34),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.3,
              letterSpacing: 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: TextButton(
              onPressed: onRetry,
              child: Text(
                context.getText(AppKeys.retryUpper),
                style: const TextStyle(
                  color: AppColors.teal700,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
