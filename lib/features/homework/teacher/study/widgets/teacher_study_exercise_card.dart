import 'package:numi/core/theme/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_exercise_helpers.dart';
import 'package:numi/features/homework/teacher/study/helpers/teacher_study_helpers.dart';

class TeacherStudyExerciseCard extends StatelessWidget {
  const TeacherStudyExerciseCard({
    super.key,
    required this.exercise,
    required this.scale,
    required this.onTap,
  });

  final ClassroomExercise exercise;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final exerciseId = exercise.stableId?.toString() ?? '-';
    final dateParts = teacherStudyDateParts(exercise.endDate);
    final dueDate = teacherStudyDateLabel(context, exercise.endDate);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14 * scale),
        child: Ink(
          padding: EdgeInsets.fromLTRB(
            12 * scale,
            10 * scale,
            12 * scale,
            10 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(color: const Color(0xFFE5ECEF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 2 * scale,
                offset: Offset(0, 1 * scale),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60 * scale,
                    height: 55 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF).withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dateParts?.day ?? '--',
                          style: GoogleFonts.andika(
                            color: AppColors.navy900,
                            fontSize: FontSize.large * scale,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        if (dateParts != null) ...[
                          SizedBox(height: 2 * scale),
                          Text(
                            context.formatText(AppKeys.teacherStudyMonth, {
                              'month': dateParts.month,
                            }),
                            style: GoogleFonts.andika(
                              color: const Color(0xFF6B7280),
                              fontSize: FontSize.caption * 0.77 * scale,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacherExerciseTitle(context, exercise),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: AppColors.navy900,
                            fontSize: FontSize.normal * scale,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: 5 * scale),
                        Text(
                          context.formatText(AppKeys.teacherAssignmentId, {
                            'id': exerciseId,
                          }),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: const Color(0xFF7B8494),
                            fontSize: FontSize.caption * scale,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (dueDate != null) ...[
                Divider(height: 16 * scale, color: const Color(0xFFE9EDF0)),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/teacher_homework_detail_calendar.svg',
                      width: 15 * scale,
                      height: 15 * scale,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF4B5563),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 7 * scale),
                    Expanded(
                      child: Text(
                        context.formatText(AppKeys.teacherStudyDueDate, {
                          'date': dueDate,
                        }),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: const Color(0xFF4B5563),
                          fontSize: FontSize.caption * scale,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
