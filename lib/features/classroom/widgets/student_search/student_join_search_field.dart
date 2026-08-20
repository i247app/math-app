import 'package:numi/features/classroom/widgets/student_search/student_class_search_assets.dart';
import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';

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
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      textAlignVertical: TextAlignVertical.center,
      style: context.textStyles.bodyLarge?.copyWith(
        color: colors.textPrimary,
        fontSize: FontSize.normal,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      decoration: InputDecoration(
        hintText: context.getText(AppKeys.studentClassCodeHint),
        hintStyle: context.textStyles.bodyLarge?.copyWith(
          color: colors.inputHint,
          fontSize: FontSize.normal,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: colors.inputSurface,
        contentPadding: const EdgeInsets.fromLTRB(19, 14, 19, 10),
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
            color: colors.brandStrong.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
