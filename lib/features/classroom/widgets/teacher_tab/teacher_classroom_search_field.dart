import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class TeacherClassroomSearchField extends StatelessWidget {
  const TeacherClassroomSearchField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.inputSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search, color: colors.brandStrong, size: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: TextField(
                controller: controller,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: FontSize.normal,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: context.getText(AppKeys.teacherSearchClassroomHint),
                  hintStyle: TextStyle(
                    color: colors.inputHint,
                    fontSize: FontSize.normal,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 4),
                  isDense: true,
                ),
              ),
            ),
          ),
          Icon(Icons.tune, color: colors.brandStrong, size: 24),
        ],
      ),
    );
  }
}
