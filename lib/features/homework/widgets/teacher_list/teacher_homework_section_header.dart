import 'package:numi/core/theme/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_exercise_copy.dart';
import 'package:numi/shared/widgets/app_section_header.dart';

class TeacherHomeworkSectionHeader extends StatelessWidget {
  const TeacherHomeworkSectionHeader({super.key, required this.purpose});

  final String purpose;

  @override
  Widget build(BuildContext context) {
    final copy = teacherExerciseCopy(purpose);
    return AppSectionHeader(
      title: context.getText(copy.createdTitleKey),
      titleStyle: GoogleFonts.andika(
        color: AppColors.navy900,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 28 / 20,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/teacher_homework_sort.svg',
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 4),
          Text(
            context.getText(AppKeys.teacherAssignmentNewest),
            style: GoogleFonts.andika(
              color: const Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
