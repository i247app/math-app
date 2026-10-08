import 'package:flutter/material.dart';

import 'package:numi/shared/widgets/small_coral_add_button.dart';

class TeacherMemberAddButton extends StatelessWidget {
  const TeacherMemberAddButton({super.key, required this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) =>
      SmallCoralAddButton(width: 82, onTap: onTap);
}
