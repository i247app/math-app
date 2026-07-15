import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_exercise_helpers.dart';

class TeacherAssignmentCard extends StatelessWidget {
  const TeacherAssignmentCard({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  final ClassroomExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final exerciseId = exercise.stableId?.toString() ?? '-';
    final dateParts = teacherExerciseDateParts(exercise.endDate);
    return Material(
      color: colors.elevatedSurface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 82,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 48,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dateParts.day,
                      style: GoogleFonts.andika(
                        color: colors.brandStrong,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    Text(
                      dateParts.month,
                      style: GoogleFonts.andika(
                        color: colors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        teacherExerciseTitle(context, exercise),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 17.5 / 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        context.formatText(AppKeys.teacherAssignmentId, {
                          'id': exerciseId,
                        }),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 16 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(
                  'assets/images/teacher_homework_more.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
