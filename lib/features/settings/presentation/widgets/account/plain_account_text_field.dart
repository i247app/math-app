import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/font_size.dart';

class PlainAccountTextField extends StatelessWidget {
  const PlainAccountTextField({
    super.key,
    required this.controller,
    required this.enabled,
    this.keyboardType,
    this.textStyle,
    this.hintText,
  });

  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextStyle? textStyle;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final style =
        textStyle ??
        GoogleFonts.andika(
          color: AppColors.textPrimary,
          fontSize: FontSize.large,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 0,
        );

    return TextField(
      controller: controller,
      readOnly: !enabled,
      canRequestFocus: enabled,
      enableInteractiveSelection: enabled,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.done,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: style,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: style.copyWith(
          color: style.color?.withValues(alpha: 0.45),
          fontWeight: FontWeight.w500,
        ),
        filled: false,
        isCollapsed: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
