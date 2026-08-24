import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';
import 'package:numi/features/homework/widgets/teacher_detail/teacher_assignment_stat.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_exercise_helpers.dart';

class TeacherAssignmentStatDue extends StatelessWidget {
  const TeacherAssignmentStatDue(this.exercise, {super.key});

  final ClassroomExercise? exercise;

  @override
  Widget build(BuildContext context) {
    return TeacherAssignmentStat(
      label: context.getText(AppKeys.teacherAssignmentDueLabel),
      iconAsset: 'assets/icons/teacher-homework-detail-calendar.svg',
      value: teacherExerciseDueDate(context, exercise),
      valueFontSize: FontSize.xs,
    );
  }
}
