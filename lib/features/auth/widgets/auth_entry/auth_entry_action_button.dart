import 'package:flutter/material.dart';

import 'package:numi/features/auth/widgets/auth_action_button.dart';

class AuthEntryActionButton extends StatelessWidget {
  const AuthEntryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isBusy = false,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return AuthActionButton(
      label: label,
      onPressed: onPressed,
      layout: AuthActionButtonLayout.compact,
      isBusy: isBusy,
      uppercase: true,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      textStyle: textStyle,
    );
  }
}
