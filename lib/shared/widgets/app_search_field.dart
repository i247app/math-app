import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onFilterPressed,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: colors.inputSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 8,
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
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: context.textStyles.bodyLarge?.copyWith(
              color: colors.inputHint,
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w700,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colors.brandStrong,
              size: 23,
            ),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      controller.clear();
                      onChanged?.call('');
                    },
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.brandStrong,
                      size: 20,
                    ),
                  )
                : onFilterPressed == null
                ? null
                : IconButton(
                    onPressed: onFilterPressed,
                    icon: Icon(
                      Icons.tune_rounded,
                      color: colors.brandStrong,
                      size: 21,
                    ),
                  ),
            border: InputBorder.none,
            isCollapsed: true,
            contentPadding: const EdgeInsets.fromLTRB(0, 13, 0, 9),
          ),
        ),
      ),
    );
  }
}
