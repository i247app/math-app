import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/features/homework/domain/models/classroom_exercise.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/homework/widgets/student_list/student_homework_helpers.dart';
import 'package:numi/features/homework/widgets/student_list/student_homework_status_badge.dart';

class StudentHomeworkAssignmentCard extends StatelessWidget {
  const StudentHomeworkAssignmentCard({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  final ClassroomExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Material(
      color: colors.elevatedSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Text(
                      studentHomeworkCreatedDate(exercise),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.andika(
                        color: colors.textSecondary,
                        fontSize: FontSize.xxs,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                      ),
                    ),
                  ),
                  StudentHomeworkStatusBadge(exercise: exercise),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  studentHomeworkTitle(exercise),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: colors.textPrimary,
                    fontSize: FontSize.large,
                    fontWeight: FontWeight.w700,
                    height: 28 / 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: Text(
                  studentHomeworkQuestionCount(context, exercise),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: colors.textSecondary,
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w400,
                    height: 20 / 14,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 17),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colors.border.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/student-homework-calendar.svg',
                      width: 12,
                      height: 13.33,
                    ),
                    Expanded(
                      child: Text(
                        studentHomeworkDueDate(context, exercise),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: colors.textSecondary,
                          fontSize: FontSize.normal,
                          fontWeight: FontWeight.w400,
                          height: 24 / 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
