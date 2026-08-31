import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/homework/domain/models/classroom_exercise.dart';
import 'package:numi/features/homework/widgets/teacher_detail/teacher_assignment_stat.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_exercise_helpers.dart';

class TeacherAssignmentStatQuestions extends StatelessWidget {
  const TeacherAssignmentStatQuestions(this.exercise, {super.key});

  final ClassroomExercise? exercise;

  @override
  Widget build(BuildContext context) {
    return TeacherAssignmentStat(
      label: context.getText(AppKeys.teacherAssignmentQuestionCountLabel),
      iconAsset: 'assets/icons/teacher-homework-detail-questions.svg',
      value: teacherExerciseQuestionCount(context, exercise),
      valueFontSize: FontSize.normal,
    );
  }
}
