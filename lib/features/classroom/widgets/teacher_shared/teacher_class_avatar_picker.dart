import 'dart:io';

import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class TeacherClassAvatarPicker extends StatelessWidget {
  const TeacherClassAvatarPicker({
    super.key,
    required this.avatarPath,
    required this.onTap,
  });
  final String? avatarPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E3E6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF747781),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  image: avatarPath == null
                      ? null
                      : DecorationImage(
                          image: FileImage(File(avatarPath!)),
                          fit: BoxFit.cover,
                        ),
                ),
                child: avatarPath == null
                    ? const Icon(
                        Icons.add_a_photo_outlined,
                        color: Color(0xFF747781),
                        size: 34,
                      )
                    : null,
              ),
              Positioned(
                right: -7,
                bottom: -7,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.teal520,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 15,
                        spreadRadius: -3,
                        offset: Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 6,
                        spreadRadius: -4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          context.getText(AppKeys.teacherClassImageLabel),
          style: const TextStyle(
            color: Color(0xFF444650),
            fontSize: FontSize.normal,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
