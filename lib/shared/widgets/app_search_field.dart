import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/theme/app_radius.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';

enum AppSearchFieldAppearance { standard, pill, filled, outlined }

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onFilterPressed,
    this.appearance = AppSearchFieldAppearance.standard,
    this.autofocus = false,
    this.showDefaultPrefixIcon = true,
    this.showClearButton = true,
    this.hapticFeedbackOnClear = true,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.textStyle,
    this.hintStyle,
    this.contentPadding,
    this.height,
    this.borderRadius,
    this.focusedBorderOpacity = 0.35,
    this.clearIconColor,
    this.clearIconSize = 20,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterPressed;
  final AppSearchFieldAppearance appearance;
  final bool autofocus;
  final bool showDefaultPrefixIcon;
  final bool showClearButton;
  final bool hapticFeedbackOnClear;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final double? height;
  final double? borderRadius;
  final double focusedBorderOpacity;
  final Color? clearIconColor;
  final double clearIconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final resolvedRadius =
        borderRadius ??
        switch (appearance) {
          AppSearchFieldAppearance.standard => AppRadius.r24,
          AppSearchFieldAppearance.pill => 999,
          AppSearchFieldAppearance.filled => 20,
          AppSearchFieldAppearance.outlined => 16,
        };
    final resolvedHeight =
        height ??
        switch (appearance) {
          AppSearchFieldAppearance.standard => 42.0,
          AppSearchFieldAppearance.pill => 49.0,
          AppSearchFieldAppearance.filled ||
          AppSearchFieldAppearance.outlined => null,
        };
    final usesOuterDecoration =
        appearance == AppSearchFieldAppearance.standard ||
        appearance == AppSearchFieldAppearance.pill;
    final resolvedTextStyle =
        textStyle ??
        context.textStyles.bodyLarge?.copyWith(
          color: colors.textPrimary,
          fontSize: FontSize.normal,
          fontWeight: appearance == AppSearchFieldAppearance.pill
              ? FontWeight.w600
              : FontWeight.w700,
        );
    final resolvedHintStyle =
        hintStyle ??
        context.textStyles.bodyLarge?.copyWith(
          color: colors.inputHint,
          fontSize: FontSize.normal,
          fontWeight: appearance == AppSearchFieldAppearance.pill
              ? FontWeight.w500
              : FontWeight.w700,
        );
    final resolvedContentPadding =
        contentPadding ??
        switch (appearance) {
          AppSearchFieldAppearance.standard => const EdgeInsets.fromLTRB(
            0,
            13,
            0,
            9,
          ),
          AppSearchFieldAppearance.pill => const EdgeInsets.fromLTRB(
            0,
            14,
            16,
            12,
          ),
          AppSearchFieldAppearance.filled => const EdgeInsets.fromLTRB(
            19,
            14,
            19,
            10,
          ),
          AppSearchFieldAppearance.outlined => const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            12,
          ),
        };
    final resolvedPrefixIcon =
        prefixIcon ??
        (showDefaultPrefixIcon
            ? Icon(Icons.search_rounded, color: colors.brandStrong, size: 23)
            : null);
    final emptySuffixIcon =
        suffixIcon ??
        (onFilterPressed == null
            ? null
            : IconButton(
                onPressed: onFilterPressed,
                icon: Icon(
                  Icons.tune_rounded,
                  color: colors.brandStrong,
                  size: 21,
                ),
              ));

    InputBorder fieldBorder = InputBorder.none;
    InputBorder enabledBorder = InputBorder.none;
    InputBorder focusedBorder = InputBorder.none;
    if (appearance == AppSearchFieldAppearance.filled) {
      fieldBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(resolvedRadius),
        borderSide: BorderSide.none,
      );
      enabledBorder = fieldBorder;
      focusedBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(resolvedRadius),
        borderSide: BorderSide(
          color: colors.brandStrong.withValues(alpha: focusedBorderOpacity),
        ),
      );
    } else if (appearance == AppSearchFieldAppearance.outlined) {
      fieldBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(resolvedRadius),
        borderSide: BorderSide(color: colors.border),
      );
      enabledBorder = fieldBorder;
      focusedBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(resolvedRadius),
        borderSide: BorderSide(color: colors.brandStrong),
      );
    }

    return Container(
      height: resolvedHeight,
      decoration: usesOuterDecoration
          ? BoxDecoration(
              color: colors.inputSurface,
              borderRadius: BorderRadius.circular(resolvedRadius),
              border: Border.all(
                color: colors.border,
                width: appearance == AppSearchFieldAppearance.pill ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: appearance == AppSearchFieldAppearance.pill
                      ? 5
                      : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : null,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          autofocus: autofocus,
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          style: resolvedTextStyle,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: resolvedHintStyle,
            prefixIcon: resolvedPrefixIcon,
            prefixIconConstraints: prefixIconConstraints,
            suffixIcon: showClearButton && value.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      if (hapticFeedbackOnClear) {
                        HapticFeedback.selectionClick();
                      }
                      controller.clear();
                      onChanged?.call('');
                    },
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    icon: Icon(
                      Icons.close_rounded,
                      color: clearIconColor ?? colors.brandStrong,
                      size: clearIconSize,
                    ),
                  )
                : emptySuffixIcon,
            suffixIconConstraints: suffixIconConstraints,
            filled: !usesOuterDecoration,
            fillColor: usesOuterDecoration ? null : colors.inputSurface,
            border: fieldBorder,
            enabledBorder: enabledBorder,
            focusedBorder: focusedBorder,
            isCollapsed: usesOuterDecoration,
            contentPadding: resolvedContentPadding,
          ),
        ),
      ),
    );
  }
}
