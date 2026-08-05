import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';

class StudentHomeworkSearchField extends StatelessWidget {
  const StudentHomeworkSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      textAlignVertical: TextAlignVertical.center,
      style: GoogleFonts.andika(
        color: AppColors.textNavy,
        fontSize: FontSize.normal,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
      ),
      decoration: InputDecoration(
        hintText: context.getText(AppKeys.studentHomeworkSearchHint),
        hintStyle: GoogleFonts.andika(
          color: const Color(0xFF515F54).withValues(alpha: 0.7),
          fontSize: FontSize.normal,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
        ),
        filled: true,
        fillColor: const Color(0xFFEBEEF1),
        contentPadding: const EdgeInsets.fromLTRB(19, 14, 19, 10),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 19, right: 9),
          child: Image.asset(
            'assets/icons/student-homework-search.png',
            width: 19,
            height: 19,
            opacity: const AlwaysStoppedAnimation<double>(0.7),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 47,
          minHeight: 19,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.teal500.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}
