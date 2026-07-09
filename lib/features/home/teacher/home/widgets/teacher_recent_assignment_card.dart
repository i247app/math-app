import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/features/homework/presentation/teacher_homework_screen.dart';

class TeacherRecentAssignmentCard extends StatelessWidget {
  const TeacherRecentAssignmentCard({
    super.key,
    required this.scale,
    required this.assignment,
    required this.onTap,
  });

  final double scale;
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
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0x33C4C6D2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A002B6A),
            blurRadius: 20 * scale,
            spreadRadius: -4 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24 * scale),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(18 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58 * scale,
                  height: 42 * scale,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBFF),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dateParts.day,
                        style: GoogleFonts.andika(
                          color: AppColors.navy900,
                          fontSize: FontSize.large * scale,
                          fontWeight: FontWeight.w900,
                          height: 0.95,
                        ),
                      ),
                      Text(
                        dateParts.month,
                        style: GoogleFonts.andika(
                          color: AppColors.textCoolMuted,
                          fontSize: FontSize.caption * 0.7 * scale,
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
                    fontSize: FontSize.large * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  timeLabel ??
                      teacherExerciseQuestionCount(context, assignment),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: AppColors.textCoolMuted,
                    fontSize: FontSize.caption * scale,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
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
