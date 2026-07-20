import 'dart:ui';
import 'package:numi/core/theme/font_size.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/features/homework/widgets/teacher_detail/teacher_assignment_detail_helpers.dart';
import 'package:numi/features/homework/widgets/teacher_detail/teacher_assignment_info_row.dart';
import 'package:numi/features/homework/widgets/teacher_detail/teacher_assignment_stat_due.dart';
import 'package:numi/features/homework/widgets/teacher_detail/teacher_assignment_stat_questions.dart';
import 'package:numi/features/homework/widgets/teacher_detail/teacher_assignment_switch.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_exercise_helpers.dart';

class TeacherAssignmentInfoCard extends StatelessWidget {
  const TeacherAssignmentInfoCard({
    super.key,
    required this.exercise,
    required this.visibility,
    required this.onVisibilityChanged,
  });

  final ClassroomExercise? exercise;
  final String? visibility;
  final ValueChanged<String> onVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: colors.elevatedSurface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: colors.border.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/teacher_homework_detail_class.svg',
                    width: 17,
                    height: 14,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        teacherExerciseClassLabel(context, exercise),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: colors.textSecondary,
                          fontSize: FontSize.small,
                          fontWeight: FontWeight.w400,
                          height: 24 / 14,
                        ),
                      ),
                    ),
                  ),
                  TeacherAssignmentSwitch(
                    visibility: visibility,
                    onChanged: onVisibilityChanged,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  teacherExerciseTitle(context, exercise),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: colors.textPrimary,
                    fontSize: FontSize.large,
                    fontWeight: FontWeight.w700,
                    height: 36 / 18,
                  ),
                ),
              ),
              if (exerciseInfoRows(context, exercise).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    children: [
                      for (final row in exerciseInfoRows(context, exercise))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: TeacherAssignmentInfoRow(row),
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.only(top: 19),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colors.border.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 30,
                    children: [
                      Expanded(child: TeacherAssignmentStatDue(exercise)),
                      Expanded(child: TeacherAssignmentStatQuestions(exercise)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
