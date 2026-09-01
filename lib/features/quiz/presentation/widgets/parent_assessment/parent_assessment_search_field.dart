import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/shared/widgets/app_search_field.dart';

class ParentAssessmentSearchField extends StatelessWidget {
  const ParentAssessmentSearchField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppSearchField(
      controller: controller,
      hintText: context.getText(AppKeys.searchHint),
    );
  }
}
