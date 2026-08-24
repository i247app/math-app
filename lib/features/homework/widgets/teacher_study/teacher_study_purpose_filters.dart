import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';
import 'package:numi/features/homework/widgets/teacher_study/teacher_study_filter_chip.dart';

class TeacherStudyPurposeFilters extends StatelessWidget {
  const TeacherStudyPurposeFilters({
    super.key,
    required this.selectedPurpose,
    required this.onSelected,
  });

  final String selectedPurpose;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        TeacherStudyFilterChip(
          label: context.getText(AppKeys.teacherAssignments),
          selected: selectedPurpose == classroomExercisePurposeHomework,
          onTap: () => onSelected(classroomExercisePurposeHomework),
        ),
        TeacherStudyFilterChip(
          label: context.getText(AppKeys.teacherAssessments),
          selected: selectedPurpose == classroomExercisePurposeExam,
          onTap: () => onSelected(classroomExercisePurposeExam),
        ),
      ],
    );
  }
}
