import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/shared/layouts/page_header.dart';

class TeacherClassroomHeader extends StatelessWidget {
  const TeacherClassroomHeader({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return PageHeader(
      title: context.getText(AppKeys.studentClassroom),
      scale: scale,
      actionWidth: 40,
      horizontalPadding: 18,
      verticalPadding: 6,
    );
  }
}
