import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/features/classroom/helpers/student_class_detail_helpers.dart';
import 'package:numi_flutter/features/classroom/presentation/student_class_detail_style.dart';
import 'package:numi_flutter/features/classroom/widgets/student_detail/student_class_empty_panel.dart';
import 'package:numi_flutter/features/classroom/widgets/student_detail/student_class_refresh_label.dart';
import 'package:numi_flutter/features/classroom/widgets/student_detail/student_class_section_title.dart';
import 'package:numi_flutter/features/classroom/widgets/student_detail/student_class_upcoming_deadline_tile.dart';
import 'package:numi_flutter/features/homework/presentation/student_homework_attempt_screen.dart';
import 'package:numi_flutter/features/homework/student_homework_open_guard.dart';

class StudentClassUpcomingDeadlineSection extends StatelessWidget {
  const StudentClassUpcomingDeadlineSection({
    super.key,
    required this.profileId,
    required this.exercises,
    required this.isLoading,
  });

  final int profileId;
  final List<ClassroomExercise> exercises;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final upcomingExercises = upcomingStudentHomeworkExercises(exercises);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StudentClassSectionTitle(
                context.getText(AppKeys.studentClassUpcomingDeadlines),
              ),
            ),
            Text(
              context.getText(AppKeys.studentClassAll),
              style: GoogleFonts.andika(
                color: studentClassPink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoading && upcomingExercises.isEmpty)
          const SizedBox(
            height: 72,
            child: Center(
              child: CircularProgressIndicator(color: studentClassTeal),
            ),
          )
        else if (upcomingExercises.isEmpty)
          StudentClassEmptyPanel(
            message: context.getText(AppKeys.studentNoHomeworkMessage),
          )
        else
          for (var index = 0; index < upcomingExercises.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == upcomingExercises.length - 1 ? 0 : 10,
              ),
              child: StudentClassUpcomingDeadlineTile(
                exercise: upcomingExercises[index],
                onTap: () =>
                    _openHomeworkAttempt(context, upcomingExercises[index]),
              ),
            ),
        if (isLoading && upcomingExercises.isNotEmpty)
          const StudentClassRefreshLabel(),
      ],
    );
  }

  void _openHomeworkAttempt(BuildContext context, ClassroomExercise exercise) {
    if (studentClassHomeworkIsSubmitted(exercise)) {
      _showSnack(context, AppKeys.studentHomeworkAlreadySubmitted);
      return;
    }

    if (showStudentHomeworkNotOpenSnackIfNeeded(context, exercise)) {
      return;
    }

    final exerciseId = exercise.stableId;
    if (exerciseId == null) {
      _showSnack(context, AppKeys.studentHomeworkMissingExercise);
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => StudentHomeworkAttemptScreen(
          exerciseId: exerciseId,
          profileId: profileId,
          initialExercise: exercise,
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String messageKey) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.getText(messageKey)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1400),
        ),
      );
  }
}
