import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/shared/widgets/app_search_field.dart';

class TeacherStudySearchField extends StatelessWidget {
  const TeacherStudySearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSearchField(
      controller: controller,
      hintText: context.getText(AppKeys.teacherAssignmentSearchHint),
      onChanged: onChanged,
    );
  }
}
