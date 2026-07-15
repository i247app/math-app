import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_input.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_label.dart';

class CreateHomeworkLabeledInput extends StatelessWidget {
  const CreateHomeworkLabeledInput({
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
      children: [
        CreateHomeworkLabel(context.getText(labelKey)),
        const SizedBox(height: 8),
        CreateHomeworkInput(
          controller: controller,
          hintKey: labelKey,
          height: 51,
        ),
      ],
    );
  }
}
