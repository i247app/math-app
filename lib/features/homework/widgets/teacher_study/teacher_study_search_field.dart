import 'package:numi/core/theme/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';

class TeacherStudySearchField extends StatelessWidget {
  const TeacherStudySearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 49,
      padding: const EdgeInsets.fromLTRB(22, 0, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFCCCCCC).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/teacher_homework_search.svg',
            width: 18,
            height: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 18),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                textInputAction: TextInputAction.search,
                textAlignVertical: TextAlignVertical.center,
                style: GoogleFonts.andika(
                  color: AppColors.textInkDark,
                  fontSize: FontSize.normal,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: context.getText(
                    AppKeys.teacherAssignmentSearchHint,
                  ),
                  hintStyle: GoogleFonts.andika(
                    color: const Color(0xFFDCBFC8),
                    fontSize: FontSize.normal,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.only(top: 4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SvgPicture.asset(
              'assets/images/teacher_homework_filter.svg',
              width: 18,
              height: 18,
            ),
          ),
        ],
      ),
    );
  }
}
