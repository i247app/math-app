import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/auth/models/signup_role.dart';
import 'package:numi/features/auth/widgets/signup/signup_role_card.dart';

class SignupRoleSelector extends StatelessWidget {
  const SignupRoleSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SignupRole? value;
  final ValueChanged<SignupRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final role in SignupRole.values) ...[
          Expanded(
            child: SignupRoleCard(
              label: context.getText(_labelKey(role)),
              imagePath: _imagePath(role),
              isSelected: value == role,
              onTap: () => onChanged(role),
            ),
          ),
          if (role != SignupRole.values.last) const SizedBox(width: 10),
        ],
      ],
    );
  }

  static String _labelKey(SignupRole role) {
    return switch (role) {
      SignupRole.student => AppKeys.signupRoleStudent,
      SignupRole.parent => AppKeys.signupRoleParent,
      SignupRole.teacher => AppKeys.signupRoleTeacher,
    };
  }

  static String _imagePath(SignupRole role) {
    return switch (role) {
      SignupRole.student => 'assets/images/student-icon.png',
      SignupRole.parent => 'assets/images/parent-icon.png',
      SignupRole.teacher => 'assets/images/teacher-icon.png',
    };
  }
}
