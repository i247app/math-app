import 'package:flutter/material.dart';

import 'package:numi_flutter/features/settings/widgets/account/account_field_shell.dart';
import 'package:numi_flutter/features/settings/widgets/account/plain_account_text_field.dart';

class AccountTextField extends StatelessWidget {
  const AccountTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.isEditing,
    required this.scale,
    this.trailing,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final double scale;
  final Widget? trailing;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return AccountFieldShell(
      label: label,
      trailing: trailing,
      scale: scale,
      child: PlainAccountTextField(
        controller: controller,
        enabled: isEditing,
        keyboardType: keyboardType,
        scale: scale,
      ),
    );
  }
}
