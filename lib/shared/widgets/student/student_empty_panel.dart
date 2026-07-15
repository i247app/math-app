import 'package:flutter/material.dart';
import 'package:numi/features/home/student/home/widgets/student_message_panel.dart';

class StudentEmptyPanel extends StatelessWidget {
  const StudentEmptyPanel({
    super.key,
    required this.scale,
    required this.icon,
    required this.title,
    required this.message,
  });

  final double scale;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return StudentMessagePanel(
      scale: scale,
      icon: icon,
      title: title,
      message: message,
    );
  }
}
