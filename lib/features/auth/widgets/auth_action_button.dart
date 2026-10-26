import 'package:flutter/material.dart';

import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

enum AuthActionButtonLayout { fullWidth, compact }

class AuthActionButton extends StatelessWidget {
  const AuthActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.layout = AuthActionButtonLayout.fullWidth,
    this.isBusy = false,
    this.uppercase = true,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  });

  static const _compactWidth = 230.0;
  static const _height = 58.0;

  final String label;
  final VoidCallback? onPressed;
  final AuthActionButtonLayout layout;
  final bool isBusy;
  final bool uppercase;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final labelColor =
        foregroundColor ?? Theme.of(context).colorScheme.onPrimary;
    final button = SizedBox(
      width: layout == AuthActionButtonLayout.fullWidth
          ? double.infinity
          : _compactWidth,
      height: _height,
      child: ElevatedButton(
        onPressed: isBusy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? colors.brandStrong,
          foregroundColor: labelColor,
          disabledBackgroundColor: isBusy
              ? backgroundColor ?? colors.disabledBackground
              : colors.disabledBackground,
          disabledForegroundColor: colors.disabledForeground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: isBusy
              ? SizedBox(
                  key: const ValueKey('busy'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: labelColor,
                  ),
                )
              : _AuthActionButtonLabel(
                  key: ValueKey(label),
                  label: uppercase ? label.toUpperCase() : label,
                  textStyle: textStyle,
                ),
        ),
      ),
    );

    if (layout == AuthActionButtonLayout.compact) {
      return Center(child: button);
    }

    return button;
  }
}

class _AuthActionButtonLabel extends StatelessWidget {
  const _AuthActionButtonLabel({
    super.key,
    required this.label,
    this.textStyle,
  });

  final String label;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium!
            .copyWith(
              color: DefaultTextStyle.of(context).style.color,
              fontSize: FontSize.large,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: 0,
            )
            .merge(textStyle)
            .copyWith(color: DefaultTextStyle.of(context).style.color),
      ),
    );
  }
}
