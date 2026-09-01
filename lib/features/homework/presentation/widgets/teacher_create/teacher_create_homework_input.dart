import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';

class CreateHomeworkInput extends StatelessWidget {
  const CreateHomeworkInput({
    super.key,
    required this.controller,
    required this.hintKey,
    required this.height,
    this.radius = 16,
    this.maxLines = 1,
    this.textAlignVertical = TextAlignVertical.center,
    this.focusNode,
    this.errorText,
  });

  final TextEditingController controller;
  final String hintKey;
  final double height;
  final double radius;
  final int maxLines;
  final TextAlignVertical textAlignVertical;
  final FocusNode? focusNode;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: maxLines,
            textAlignVertical: textAlignVertical,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            style: GoogleFonts.andika(
              color: AppColors.textInkDark,
              fontSize: FontSize.small,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: context.getText(hintKey),
              hintStyle: GoogleFonts.andika(
                color: AppColors.textInkDark.withValues(alpha: 0.7),
                fontSize: FontSize.small,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 17,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(
                  color: hasError
                      ? Theme.of(context).colorScheme.error
                      : const Color(0xFFDDE4E6),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(
                  color: hasError
                      ? Theme.of(context).colorScheme.error
                      : AppColors.teal520,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        if (errorText case final error?)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              error,
              style: GoogleFonts.andika(
                color: Theme.of(context).colorScheme.error,
                fontSize: FontSize.xxs,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
