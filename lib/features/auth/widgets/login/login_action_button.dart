import 'package:flutter/material.dart';

import 'package:numi_flutter/features/auth/widgets/shared/auth_action_button.dart';

class LoginActionButton extends StatelessWidget {
  const LoginActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AuthActionButton(
      label: label,
      onPressed: onPressed,
      uppercase: true,
    );
  }
}
