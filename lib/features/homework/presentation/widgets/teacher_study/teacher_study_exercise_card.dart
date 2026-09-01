import 'package:numi/core/theme/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/homework/domain/models/classroom_exercise.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/homework/application/read_models/teacher_exercise_read_model.dart';
import 'package:numi/features/homework/presentation/helpers/teacher_study_helpers.dart';

class TeacherStudyExerciseCard extends StatelessWidget {
  const TeacherStudyExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  final ClassroomExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final exerciseId = exercise.stableId?.toString() ?? '-';
    final dateParts = teacherStudyDateParts(exercise.endDate);
    final dueDate = teacherStudyDateLabel(context, exercise.endDate);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5ECEF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                spacing: 16,
                children: [
                  Container(
                    width: 60,
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF).withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 2,
                      children: [
                        Text(
                          dateParts?.day ?? '--',
                          style: GoogleFonts.andika(
                            color: AppColors.navy900,
                            fontSize: FontSize.large,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        if (dateParts != null)
                          Text(
                            context.formatText(AppKeys.teacherStudyMonth, {
                              'month': dateParts.month,
                            }),
                            style: GoogleFonts.andika(
                              color: const Color(0xFF6B7280),
                              fontSize: FontSize.caption * 0.77,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        Text(
                          teacherExerciseTitle(context, exercise),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: AppColors.navy900,
                            fontSize: FontSize.normal,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        Text(
                          context.formatText(AppKeys.teacherAssignmentId, {
                            'id': exerciseId,
                          }),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: const Color(0xFF7B8494),
                            fontSize: FontSize.caption,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (dueDate != null) ...[
                const Divider(height: 16, color: Color(0xFFE9EDF0)),
                Row(
                  spacing: 7,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/teacher-homework-detail-calendar.svg',
                      width: 15,
                      height: 15,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF4B5563),
                        BlendMode.srcIn,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        context.formatText(AppKeys.teacherStudyDueDate, {
                          'date': dueDate,
                        }),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: const Color(0xFF4B5563),
                          fontSize: FontSize.caption,
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
