import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/theme/app_colors.dart';

class StudentJoinStateCard extends StatelessWidget {
  const StudentJoinStateCard({
    super.key,
    required this.assetPath,
    this.isSvg = false,
    this.titleKey,
    this.title,
    this.titleColor = AppColors.textNavy,
    required this.messageKey,
    this.actionLabelKey,
    this.onAction,
  });

  final String assetPath;
  final bool isSvg;
  final String? titleKey;
  final String? title;
  final Color titleColor;
  final String messageKey;
  final String? actionLabelKey;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E8EB)),
      ),
      child: Column(
        children: [
          isSvg
              ? SvgPicture.asset(assetPath, width: 32, height: 32)
              : Image.asset(assetPath, width: 32, height: 32),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              title ?? context.getText(titleKey!),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: FontSize.normal,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              context.getText(messageKey),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.grayText,
                fontSize: FontSize.xs,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
          if (onAction != null && actionLabelKey != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(context.getText(actionLabelKey!)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.tealActive,
                  side: const BorderSide(color: AppColors.tealActive),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
