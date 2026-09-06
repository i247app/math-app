import 'package:numi/features/classroom/widgets/student_search/student_class_search_assets.dart';
import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/shared/widgets/app_search_field.dart';

class StudentJoinSearchField extends StatelessWidget {
  const StudentJoinSearchField({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool isSearching;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return AppSearchField(
      controller: controller,
      hintText: context.getText(AppKeys.studentClassCodeHint),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      appearance: AppSearchFieldAppearance.filled,
      showDefaultPrefixIcon: false,
      showClearButton: false,
      focusedBorderOpacity: 0.3,
      textStyle: context.textStyles.bodyLarge?.copyWith(
        color: colors.textPrimary,
        fontSize: FontSize.normal,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      hintStyle: context.textStyles.bodyLarge?.copyWith(
        color: colors.inputHint,
        fontSize: FontSize.normal,
        fontWeight: FontWeight.w700,
      ),
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSearching)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                onPressed: () => onSubmitted(controller.text),
                icon: Image.asset(
                  studentJoinSearchIcon,
                  width: 19,
                  height: 19,
                  opacity: const AlwaysStoppedAnimation<double>(0.7),
                ),
                tooltip: context.getText(AppKeys.studentSearchClass),
              ),
            Image.asset(
              studentJoinScanIcon,
              width: 21,
              height: 21,
              opacity: const AlwaysStoppedAnimation<double>(0.7),
            ),
          ],
        ),
      ),
    );
  }
}
