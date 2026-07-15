import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/shared/widgets/student/student_empty_panel.dart';

class StudentHomeworkPanel extends StatelessWidget {
  const StudentHomeworkPanel({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return StudentEmptyPanel(
      scale: scale,
      icon: Icons.assignment_rounded,
      title: context.getText(AppKeys.studentNoHomeworkTitle),
      message: context.getText(AppKeys.studentNoHomeworkMessage),
    );
  }
}
