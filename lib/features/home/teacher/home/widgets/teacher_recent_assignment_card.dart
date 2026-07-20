import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_exercise_helpers.dart';

class TeacherRecentAssignmentCard extends StatelessWidget {
  const TeacherRecentAssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
  });
  final ClassroomExercise assignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateParts = teacherExerciseDateParts(
      assignment.createDt ?? assignment.startDate ?? assignment.endDate,
    );
    final timeLabel = teacherExerciseDateTimeLabel(
      assignment.createDt ?? assignment.startDate ?? assignment.endDate,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x33C4C6D2)),
        boxShadow: [
          const BoxShadow(
            color: Color(0x1A002B6A),
            blurRadius: 20,
            spreadRadius: -4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dateParts.day,
                        style: GoogleFonts.andika(
                          color: AppColors.navy900,
                          fontSize: FontSize.large,
                          fontWeight: FontWeight.w900,
                          height: 0.95,
                        ),
                      ),
                      Text(
                        dateParts.month,
                        style: GoogleFonts.andika(
                          color: AppColors.textCoolMuted,
                          fontSize: FontSize.xxxs,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  teacherExerciseTitle(context, assignment),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: AppColors.textInkDark,
                    fontSize: FontSize.large,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    timeLabel ??
                        teacherExerciseQuestionCount(context, assignment),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.andika(
                      color: AppColors.textCoolMuted,
                      fontSize: FontSize.caption,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
