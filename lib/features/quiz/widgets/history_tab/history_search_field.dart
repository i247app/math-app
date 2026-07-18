import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class HistorySearchField extends StatelessWidget {
  const HistorySearchField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: colors.inputSurface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: FontSize.normal,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText: context.getText(AppKeys.searchHint),
          hintStyle: TextStyle(
            color: colors.inputHint,
            fontSize: FontSize.normal,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 6),
            child: Icon(
              Icons.search_rounded,
              color: colors.brandStrong,
              size: 22,
            ),
          ),
          suffixIcon: IconButton(
            onPressed: HapticFeedback.selectionClick,
            icon: Icon(Icons.tune_rounded, color: colors.brandStrong, size: 22),
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 11,
            horizontal: 10,
          ),
        ),
      ),
    );
  }
}
