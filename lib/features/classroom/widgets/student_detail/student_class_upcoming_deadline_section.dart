import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/features/classroom/helpers/student_class_detail_helpers.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_empty_panel.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_section_title.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_upcoming_deadline_tile.dart';
import 'package:numi/features/homework/presentation/student_homework_attempt_screen.dart';
import 'package:numi/features/homework/student_homework_open_guard.dart';

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
                color: AppColors.magenta,
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
              child: CircularProgressIndicator(color: AppColors.teal500),
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
      ],
    );
  }

  void _openHomeworkAttempt(BuildContext context, ClassroomExercise exercise) {
    if (studentClassHomeworkIsSubmitted(exercise)) {
      _showError(context, AppKeys.studentHomeworkAlreadySubmitted);
      return;
    }

    if (showStudentHomeworkNotOpenDialogIfNeeded(context, exercise)) {
      return;
    }

    final exerciseId = exercise.stableId;
    if (exerciseId == null) {
      _showError(context, AppKeys.studentHomeworkMissingExercise);
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

  void _showError(BuildContext context, String messageKey) {
    context.showErrorDialog(context.getText(messageKey));
  }
}
