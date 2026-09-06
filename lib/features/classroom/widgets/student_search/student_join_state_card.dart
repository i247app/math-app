import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/widgets/app_state_panel.dart';

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
  }) : assert(title != null || titleKey != null),
       assert(
         (actionLabelKey == null && onAction == null) ||
             (actionLabelKey != null && onAction != null),
       );

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
    final colors = context.themeColors;
    final actionLabel = actionLabelKey == null
        ? null
        : context.getText(actionLabelKey!);

    return AppStatePanel(
      title: title ?? context.getText(titleKey!),
      message: context.getText(messageKey),
      visual: isSvg
          ? SvgPicture.asset(assetPath, width: 32, height: 32)
          : Image.asset(assetPath, width: 32, height: 32),
      padding: const EdgeInsets.all(22),
      borderRadius: 12,
      visualTitleSpacing: 10,
      titleMessageSpacing: 6,
      messageActionSpacing: 14,
      titleStyle: context.textStyles.bodyLarge?.copyWith(
        color: titleColor,
        fontSize: FontSize.normal,
        fontWeight: FontWeight.w900,
      ),
      messageStyle: context.textStyles.bodySmall?.copyWith(
        color: colors.textMuted,
        fontSize: FontSize.xs,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      action: actionLabel == null
          ? null
          : OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(actionLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.brandStrong,
                side: BorderSide(color: colors.brandStrong),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
    );
  }
}
