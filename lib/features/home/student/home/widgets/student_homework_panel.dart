import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/shared/widgets/student/student_empty_panel.dart';

class StudentHomeworkPanel extends StatelessWidget {
  const StudentHomeworkPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return StudentEmptyPanel(
      icon: Icons.assignment_rounded,
      title: context.getText(AppKeys.studentNoHomeworkTitle),
      message: context.getText(AppKeys.studentNoHomeworkMessage),
    );
  }
}
