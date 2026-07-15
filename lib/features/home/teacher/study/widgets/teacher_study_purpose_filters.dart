import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/features/home/teacher/study/widgets/teacher_study_filter_chip.dart';

class TeacherStudyPurposeFilters extends StatelessWidget {
  const TeacherStudyPurposeFilters({
    super.key,
    required this.selectedPurpose,
    required this.scale,
    required this.onSelected,
  });

  final String selectedPurpose;
  final double scale;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TeacherStudyFilterChip(
          label: context.getText(AppKeys.teacherAssignments),
          selected: selectedPurpose == classroomExercisePurposeHomework,
          scale: scale,
          onTap: () => onSelected(classroomExercisePurposeHomework),
        ),
        SizedBox(width: 8 * scale),
        TeacherStudyFilterChip(
          label: context.getText(AppKeys.teacherAssessments),
          selected: selectedPurpose == classroomExercisePurposeExam,
          scale: scale,
          onTap: () => onSelected(classroomExercisePurposeExam),
        ),
      ],
    );
  }
}
