import 'package:flutter/material.dart';

class AppInlineRetryBanner extends StatelessWidget {
  const AppInlineRetryBanner({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel,
    required this.backgroundColor,
    required this.textColor,
    required this.padding,
    required this.borderRadius,
    this.borderColor,
    this.maxLines,
    this.textHeight,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w700,
    this.leading,
    this.retryIcon,
    this.retryTooltip,
    this.actionSpacing = 8,
    this.leadingSpacing,
  });

  final String message;
  final VoidCallback onRetry;
  final String? retryLabel;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final int? maxLines;
  final double? textHeight;
  final double fontSize;
  final FontWeight fontWeight;
  final Widget? leading;
  final Widget? retryIcon;
  final String? retryTooltip;
  final double actionSpacing;
  final double? leadingSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: leadingSpacing ?? actionSpacing),
          ],
          Expanded(
            child: Text(
              message,
              maxLines: maxLines,
              overflow: maxLines == null ? null : TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: fontWeight,
                height: textHeight,
              ),
            ),
          ),
          SizedBox(width: actionSpacing),
          if (retryIcon != null)
            IconButton(
              onPressed: onRetry,
              tooltip: retryTooltip,
              icon: retryIcon!,
            )
          else
            TextButton(onPressed: onRetry, child: Text(retryLabel ?? '')),
        ],
      ),
    );
  }
}
