import 'package:flutter/material.dart';

import 'package:numi/features/homework/presentation/widgets/teacher_create/teacher_create_homework_select_field.dart';

class CreateHomeworkDateField extends StatelessWidget {
  const CreateHomeworkDateField({
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
    return CreateHomeworkSelectField(
      valueKey: hintKey,
      valueText: valueText,
      iconAsset: 'assets/icons/teacher-homework-create-calendar.svg',
      iconWidth: 18,
      iconHeight: 20,
      onTap: onTap,
    );
  }
}
