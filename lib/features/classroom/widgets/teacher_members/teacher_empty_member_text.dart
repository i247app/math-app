import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/theme/app_colors.dart';

class TeacherEmptyMemberText extends StatelessWidget {
  const TeacherEmptyMemberText({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textCoolMuted,
          fontSize: FontSize.small,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
    );
  }
}
