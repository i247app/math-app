import 'package:numi/core/theme/app_colors.dart';

import 'package:flutter/material.dart';

class TeacherAssignmentSwitch extends StatelessWidget {
  const TeacherAssignmentSwitch({
    super.key,
    required this.visibility,
    required this.onChanged,
  });

  final String? visibility;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: visibility == 'PUBLIC',
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.teal520,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: const Color(0xFFE87151),
      onChanged: (value) => onChanged(value ? 'PUBLIC' : 'PRIVATE'),
    );
  }
}
