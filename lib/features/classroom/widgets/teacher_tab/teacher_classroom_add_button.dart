import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';

class TeacherClassroomAddButton extends StatelessWidget {
  const TeacherClassroomAddButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 90,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.coralTeacher,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
