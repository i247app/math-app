import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

InputDecoration teacherInputDecoration(
  BuildContext context, {
  String? hintText,
  bool outlined = false,
}) {
  final colors = context.themeColors;
  final radius = BorderRadius.circular(outlined ? 16 : 12);
  final borderColor = outlined ? colors.border : colors.borderStrong;
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: colors.inputHint,
      fontSize: FontSize.normal,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: colors.inputSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: borderColor, width: outlined ? 2 : 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: colors.brandStrong, width: 2),
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
