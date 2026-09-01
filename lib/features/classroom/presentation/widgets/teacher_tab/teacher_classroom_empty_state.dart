import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class TeacherClassroomEmptyState extends StatelessWidget {
  const TeacherClassroomEmptyState({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textCoolMuted,
            fontSize: FontSize.normal,
          ),
        ),
      ),
    );
  }
}
