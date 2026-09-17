import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

InputDecoration teacherInputDecoration({
  String? hintText,
  bool outlined = false,
}) {
  final radius = BorderRadius.circular(outlined ? 16 : 12);
  final borderColor = outlined
      ? const Color(0xFFDDE4E6)
      : const Color(0xFFC4C6D2);
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0x806B7280),
      fontSize: FontSize.normal,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: outlined ? Colors.white : const Color(0xFFF7FAFD),
    contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: borderColor, width: outlined ? 2 : 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppColors.teal520, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: borderColor, width: outlined ? 2 : 1),
    ),
  );
}

String? nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
