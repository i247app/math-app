import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/features/homework/widgets/student_list/student_homework_helpers.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';

class StudentHomeworkStatusBadge extends StatelessWidget {
  const StudentHomeworkStatusBadge({super.key, required this.exercise});

  final ClassroomExercise exercise;

  @override
  Widget build(BuildContext context) {
    final submitted = studentHomeworkIsSubmitted(exercise);
    final overdue = studentHomeworkIsOverdue(exercise);
    final labelKey = submitted
        ? AppKeys.studentHomeworkSubmitted
        : overdue
        ? AppKeys.studentHomeworkOverdue
        : AppKeys.studentHomeworkNotSubmitted;
    final color = submitted
        ? const Color(0xFF2E7D32)
        : overdue
        ? const Color(0xFFC2410C)
        : AppColors.teal500;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          context.getText(labelKey),
          maxLines: 1,
          style: GoogleFonts.andika(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 16 / 12,
          ),
        ),
      ),
    );
  }
}
