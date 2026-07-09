import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/settings/widgets/profile_form/add_profile_field_shell.dart';

class AddProfileTextField extends StatelessWidget {
  const AddProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.scale,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final double scale;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return AddProfileFieldShell(
      label: label,
      scale: scale,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        style: GoogleFonts.andika(
          color: AppColors.textPrimary,
          fontSize: FontSize.normal * scale,
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          filled: false,
          hintStyle: GoogleFonts.andika(
            color: const Color(0xFFA8B1B2),
            fontSize: FontSize.small * scale,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          isCollapsed: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
