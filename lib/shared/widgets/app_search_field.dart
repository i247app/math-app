import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4DDDF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
          style: const TextStyle(
            color: Color(0xFF17252B),
            fontSize: FontSize.normal,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFFD8C5CC),
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w700,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF063A7B),
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
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF063A7B),
                      size: 20,
                    ),
                  )
                : onFilterPressed == null
                ? null
                : IconButton(
                    onPressed: onFilterPressed,
                    icon: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF063A7B),
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
