import 'package:flutter/material.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';

class GradeLoadError extends StatelessWidget {
  const GradeLoadError({
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
    return Container(
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28 * scale),
      ),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            color: AppColors.teal700,
            size: 34 * scale,
          ),
          SizedBox(height: 12 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w800,
              height: 1.3,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 14 * scale),
          TextButton(
            onPressed: onRetry,
            child: Text(
              context.getText(AppKeys.retryUpper),
              style: TextStyle(
                color: AppColors.teal700,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
