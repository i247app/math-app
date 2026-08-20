import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';

class TeacherHomeworkSearchField extends StatelessWidget {
  const TeacherHomeworkSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 49,
      decoration: BoxDecoration(
        color: colors.inputSurface,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: colors.border, width: 2),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          onChanged: onChanged,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          style: context.textStyles.bodyLarge?.copyWith(
            color: colors.textPrimary,
            fontSize: FontSize.normal,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: context.getText(AppKeys.teacherAssignmentSearchHint),
            hintStyle: context.textStyles.bodyLarge?.copyWith(
              color: colors.inputHint,
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: SvgPicture.asset(
                'assets/icons/teacher-homework-search.svg',
                width: 18,
                height: 18,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 48),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.brandStrong,
                      size: 20,
                    ),
                  ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.fromLTRB(0, 14, 16, 12),
          ),
        ),
      ),
    );
  }
}
