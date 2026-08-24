import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/shared/widgets/app_search_field.dart';

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
    final colors = context.themeColors;
    return AppSearchField(
      controller: controller,
      hintText: context.getText(AppKeys.studentHomeworkSearchHint),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      appearance: AppSearchFieldAppearance.filled,
      hapticFeedbackOnClear: false,
      textStyle: context.textStyles.bodyLarge?.copyWith(
        color: colors.textPrimary,
        fontSize: FontSize.normal,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
      ),
      hintStyle: context.textStyles.bodyLarge?.copyWith(
        color: colors.inputHint,
        fontSize: FontSize.normal,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 19, right: 9),
        child: Image.asset(
          'assets/icons/student-homework-search.png',
          width: 19,
          height: 19,
          opacity: const AlwaysStoppedAnimation<double>(0.7),
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 47, minHeight: 19),
      suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      clearIconColor: colors.textMuted,
      clearIconSize: 18,
    );
  }
}
