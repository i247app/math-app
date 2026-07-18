import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';

class GradeFailureNotice extends StatelessWidget {
  const GradeFailureNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.peachSoft.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.rust.withValues(alpha: 0.10)),
      ),
      child: Row(
        spacing: 10,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.rust,
            size: 20,
          ),
          Expanded(
            child: Text(
              context.getText(AppKeys.generateTestFailed),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.rust,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                height: 1.25,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
