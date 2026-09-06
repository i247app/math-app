import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom/helpers/student_class_detail_helpers.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_empty_panel.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_section_title.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_upcoming_deadline_tile.dart';
import 'package:numi/features/classroom_exercise/screens/student_classroom_exercise_attempt_screen.dart';
import 'package:numi/features/classroom_exercise/helpers/student_classroom_exercise_open_guard.dart';

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
    final upcomingExercises = upcomingStudentClassroomExerciseExercises(
      exercises,
    );
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
              style: const TextStyle(
                color: AppColors.magenta,
                fontSize: FontSize.normal,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: isLoading && upcomingExercises.isEmpty
              ? const SizedBox(
                  height: 72,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.teal500),
                  ),
                )
              : upcomingExercises.isEmpty
              ? StudentClassEmptyPanel(
                  message: context.getText(
                    AppKeys.studentNoClassroomExerciseMessage,
                  ),
                )
              : Column(
                  spacing: 10,
                  children: [
                    for (final exercise in upcomingExercises)
                      StudentClassUpcomingDeadlineTile(
                        exercise: exercise,
                        onTap: () =>
                            _openClassroomExerciseAttempt(context, exercise),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  void _openClassroomExerciseAttempt(
    BuildContext context,
    ClassroomExercise exercise,
  ) {
    if (studentClassClassroomExerciseIsSubmitted(exercise)) {
      _showError(context, AppKeys.studentClassroomExerciseAlreadySubmitted);
      return;
    }

    if (showStudentClassroomExerciseNotOpenDialogIfNeeded(context, exercise)) {
      return;
    }

    final exerciseId = exercise.stableId;
    if (exerciseId == null) {
      _showError(context, AppKeys.studentClassroomExerciseMissingExercise);
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => StudentClassroomExerciseAttemptScreen(
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
