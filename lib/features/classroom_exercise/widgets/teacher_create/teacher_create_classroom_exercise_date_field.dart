import 'package:flutter/material.dart';

import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_select_field.dart';

class CreateClassroomExerciseDateField extends StatelessWidget {
  const CreateClassroomExerciseDateField({
    super.key,
    required this.hintKey,
    required this.onTap,
    this.valueText,
  });

  final String hintKey;
  final VoidCallback onTap;
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    return CreateClassroomExerciseSelectField(
      valueKey: hintKey,
      valueText: valueText,
      iconAsset: 'assets/icons/teacher-homework-create-calendar.svg',
      iconWidth: 18,
      iconHeight: 20,
      onTap: onTap,
    );
  }
}
