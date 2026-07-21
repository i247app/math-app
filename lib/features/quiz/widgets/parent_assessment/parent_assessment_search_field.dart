import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';

class ParentAssessmentSearchField extends StatelessWidget {
  const ParentAssessmentSearchField({super.key, required this.controller});

  final TextEditingController controller;

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
      child: TextField(
        controller: controller,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          color: Color(0xFF17252B),
          fontSize: FontSize.normal,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: context.getText(AppKeys.searchHint),
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
          suffixIcon: const IconButton(
            onPressed: HapticFeedback.selectionClick,
            icon: Icon(Icons.tune_rounded, color: Color(0xFF063A7B), size: 21),
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: const EdgeInsets.fromLTRB(0, 13, 0, 9),
        ),
      ),
    );
  }
}
