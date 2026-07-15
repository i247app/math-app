import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';

class TeacherClassroomAddButton extends StatelessWidget {
  const TeacherClassroomAddButton({
    super.key,
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 90 * scale,
          height: 36 * scale,
          decoration: BoxDecoration(
            color: AppColors.coralTeacher,
            borderRadius: BorderRadius.circular(12 * scale),
          ),
          child: Icon(Icons.add, color: Colors.white, size: 24 * scale),
        ),
      ),
    );
  }
}
