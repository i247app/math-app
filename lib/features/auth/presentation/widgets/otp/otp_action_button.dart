import 'package:flutter/material.dart';

import 'package:numi/features/auth/presentation/widgets/auth_action_button.dart';

class OtpActionButton extends StatelessWidget {
  const OtpActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cleanLabel = label.replaceAll('→', '').trim();

    return AuthActionButton(
      label: cleanLabel,
      onPressed: onPressed,
      layout: AuthActionButtonLayout.compact,
      uppercase: true,
    );
  }
}
