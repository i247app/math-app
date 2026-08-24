import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_radius.dart';
import 'package:numi/core/theme/app_spacing.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';

class AppStatePanel extends StatelessWidget {
  const AppStatePanel({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.visual,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.all(22),
    this.borderRadius = 30,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.iconBackgroundColor,
    this.titleStyle,
    this.messageStyle,
    this.action,
    this.visualTitleSpacing = 14,
    this.titleMessageSpacing = AppSpacing.s8,
    this.messageActionSpacing = AppSpacing.s16,
  }) : assert(icon == null || visual == null),
       assert(
         (actionLabel == null && onAction == null) ||
             (actionLabel != null && onAction != null),
       ),
       assert(
         action == null && actionLabel == null && onAction == null ||
             action != null && actionLabel == null && onAction == null ||
             action == null && actionLabel != null && onAction != null,
       );

  final String title;
  final String message;
  final IconData? icon;
  final Widget? visual;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final Widget? action;
  final double visualTitleSpacing;
  final double titleMessageSpacing;
  final double messageActionSpacing;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final resolvedVisual =
        visual ??
        (icon == null
            ? null
            : Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color:
                      iconBackgroundColor ??
                      colors.brandStrong.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.r24),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? colors.brandStrong,
                  size: 28,
                ),
              ));
    final resolvedAction =
        action ??
        (actionLabel == null
            ? null
            : TextButton(onPressed: onAction, child: Text(actionLabel!)));

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.elevatedSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?resolvedVisual,
          Padding(
            padding: EdgeInsets.only(
              top: resolvedVisual == null ? 0 : visualTitleSpacing,
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style:
                  titleStyle ??
                  context.textStyles.bodyLarge?.copyWith(
                    color: colors.textPrimary,
                    fontSize: FontSize.normal,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: titleMessageSpacing),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style:
                  messageStyle ??
                  context.textStyles.bodySmall?.copyWith(
                    color: colors.textMuted,
                    fontSize: FontSize.caption,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
            ),
          ),
          if (resolvedAction != null)
            Padding(
              padding: EdgeInsets.only(top: messageActionSpacing),
              child: resolvedAction,
            ),
        ],
      ),
    );
  }
}
