import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/theme/app_radius.dart';
import 'package:numi/core/theme/app_spacing.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';

/// A shared section header with a title on the left and an optional action
/// button on the right.
///
/// Callers can customise typography or provide an arbitrary [trailing]
/// widget for feature-specific actions.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.scale = 1.0,
    this.titleStyle,
    this.actionStyle,
    this.actionIcon,
    this.trailing,
    this.useHaptic = true,
    this.bottom,
    this.bottomSpacing,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double scale;
  final TextStyle? titleStyle;
  final TextStyle? actionStyle;
  final IconData? actionIcon;
  final Widget? trailing;
  final bool useHaptic;
  final Widget? bottom;
  final double? bottomSpacing;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final titleToken = context.textStyles.titleMedium ?? const TextStyle();
    final actionToken = context.textStyles.bodyMedium ?? const TextStyle();
    final effectiveTitleStyle =
        titleStyle ??
        titleToken.copyWith(
          color: colors.textPrimary,
          fontSize: FontSize.normal * scale,
          fontWeight: FontWeight.w900,
          height: 1.25,
          letterSpacing: 0,
        );

    final effectiveActionStyle =
        actionStyle ??
        actionToken.copyWith(
          color: colors.accentStrong,
          fontSize: FontSize.small * scale,
          fontWeight: FontWeight.w900,
          decoration: TextDecoration.underline,
          height: 1.2,
          letterSpacing: 0,
        );

    final label = actionLabel;
    final action =
        trailing ??
        (label != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: effectiveActionStyle,
                  ),
                  if (actionIcon != null) ...[
                    SizedBox(width: 2 * scale),
                    Icon(
                      actionIcon,
                      color: effectiveActionStyle.color,
                      size: 18 * scale,
                    ),
                  ],
                ],
              )
            : null);

    final header = Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: effectiveTitleStyle,
          ),
        ),
        if (action != null) ...[
          SizedBox(width: AppSpacing.s12 * scale),
          if (onAction == null)
            action
          else
            InkWell(
              onTap: () {
                if (useHaptic) HapticFeedback.selectionClick();
                onAction!();
              },
              borderRadius: BorderRadius.circular(AppRadius.r8),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s4 * scale),
                child: action,
              ),
            ),
        ],
      ],
    );

    final bottomContent = bottom;
    if (bottomContent == null) {
      return header;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        header,
        SizedBox(height: bottomSpacing ?? AppSpacing.s8 * scale),
        bottomContent,
      ],
    );
  }
}
