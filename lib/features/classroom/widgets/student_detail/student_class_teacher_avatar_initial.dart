import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/theme/app_colors.dart';

class StudentClassTeacherAvatarInitial extends StatelessWidget {
  const StudentClassTeacherAvatarInitial({super.key, required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDF0F5),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.magenta,
          fontSize: FontSize.xxl,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
