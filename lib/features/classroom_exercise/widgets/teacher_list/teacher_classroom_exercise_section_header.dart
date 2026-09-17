import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_list/teacher_exercise_copy.dart';
import 'package:numi/shared/widgets/app_section_header.dart';

class TeacherClassroomExerciseSectionHeader extends StatelessWidget {
  const TeacherClassroomExerciseSectionHeader({
    super.key,
    required this.purpose,
  });

  final String purpose;

  @override
  Widget build(BuildContext context) {
    final copy = teacherExerciseCopy(purpose);
    return AppSectionHeader(
      title: context.getText(copy.createdTitleKey),
      titleStyle: GoogleFonts.andika(
        color: AppColors.navy900,
        fontSize: FontSize.xl,
        fontWeight: FontWeight.w800,
        height: 28 / 20,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SvgPicture.asset(
            'assets/icons/teacher-homework-sort.svg',
            width: 16,
            height: 16,
          ),
          Text(
            context.getText(AppKeys.teacherAssignmentNewest),
            style: GoogleFonts.andika(
              color: const Color(0xFF6B7280),
              fontSize: FontSize.xxs,
              fontWeight: FontWeight.w400,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
