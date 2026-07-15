import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_colors.dart';

class HistorySubmittedBadge extends StatelessWidget {
  const HistorySubmittedBadge({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56 * scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48 * scale,
            height: 48 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFE1F8F4),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.teal700.withValues(alpha: 0.26),
                width: 1.3 * scale,
              ),
            ),
            child: Icon(
              Icons.check_rounded,
              color: AppColors.teal700,
              size: 26 * scale,
            ),
          ),
          SizedBox(height: 7 * scale),
          Text(
            context.getText(AppKeys.studentHomeworkSubmitted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.teal700,
              fontSize: FontSize.caption * 0.77 * scale,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
