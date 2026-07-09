import 'package:flutter/material.dart';
import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/home/student/home/widgets/student_empty_panel.dart';

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
