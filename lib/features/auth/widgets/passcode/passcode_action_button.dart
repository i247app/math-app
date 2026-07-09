import 'package:flutter/material.dart';

import 'package:numi/features/auth/widgets/shared/auth_action_button.dart';

class PasscodeActionButton extends StatelessWidget {
  const PasscodeActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return AuthActionButton(label: label, onPressed: onPressed, isBusy: isBusy);
  }
}
