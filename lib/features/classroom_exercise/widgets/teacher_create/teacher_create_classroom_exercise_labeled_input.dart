import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_input.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_label.dart';

class CreateClassroomExerciseLabeledInput extends StatelessWidget {
  const CreateClassroomExerciseLabeledInput({
    super.key,
    required this.labelKey,
    required this.controller,
  });

  final String labelKey;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        CreateClassroomExerciseLabel(context.getText(labelKey)),
        CreateClassroomExerciseInput(
          controller: controller,
          hintKey: labelKey,
          height: 51,
        ),
      ],
    );
  }
}
