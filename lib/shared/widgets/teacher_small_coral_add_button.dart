import 'package:flutter/material.dart';

import 'package:numi/shared/widgets/small_coral_add_button.dart';

class TeacherSmallCoralAddButton extends StatelessWidget {
  const TeacherSmallCoralAddButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: SmallCoralAddButton(width: 91, onTap: onTap),
  );
}
