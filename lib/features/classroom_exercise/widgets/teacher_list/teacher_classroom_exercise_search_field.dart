import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/shared/widgets/app_search_field.dart';

class TeacherClassroomExerciseSearchField extends StatelessWidget {
  const TeacherClassroomExerciseSearchField({
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
      appearance: AppSearchFieldAppearance.pill,
      hapticFeedbackOnClear: false,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 20, right: 10),
        child: SvgPicture.asset(
          'assets/icons/teacher-homework-search.svg',
          width: 18,
          height: 18,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 48),
    );
  }
}
