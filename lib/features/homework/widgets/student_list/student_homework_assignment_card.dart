import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/features/homework/widgets/student_list/student_homework_helpers.dart';
import 'package:numi_flutter/features/homework/widgets/student_list/student_homework_status_badge.dart';
import 'package:numi_flutter/features/homework/widgets/student_list/student_homework_style.dart';

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
    return Material(
      color: Colors.white,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC4C6D2).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      studentHomeworkCreatedDate(exercise),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.andika(
                        color: studentHomeworkMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StudentHomeworkStatusBadge(exercise: exercise),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                studentHomeworkTitle(exercise),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: studentHomeworkInk,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 28 / 18,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  studentHomeworkQuestionCount(context, exercise),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: studentHomeworkMuted,
                    fontSize: 14,
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
                      color: const Color(0xFFC4C6D2).withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/student_homework_calendar.svg',
                      width: 12,
                      height: 13.33,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        studentHomeworkDueDate(context, exercise),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: studentHomeworkMuted,
                          fontSize: 16,
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
