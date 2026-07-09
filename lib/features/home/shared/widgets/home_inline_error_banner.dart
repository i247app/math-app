import 'package:flutter/material.dart';

class HomeInlineErrorBanner extends StatelessWidget {
  const HomeInlineErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
    required this.retryLabel,
    required this.backgroundColor,
    required this.textColor,
    required this.padding,
    required this.borderRadius,
    this.borderColor,
    this.maxLines,
    this.textHeight,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final int? maxLines;
  final double? textHeight;

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
          Expanded(
            child: Text(
              message,
              maxLines: maxLines,
              overflow: maxLines == null ? null : TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: textHeight,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}
