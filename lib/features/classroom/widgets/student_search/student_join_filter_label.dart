import 'package:flutter/material.dart';

import 'package:numi_flutter/features/classroom/widgets/student_search/student_class_search_style.dart';

class StudentJoinFilterLabel extends StatelessWidget {
  const StudentJoinFilterLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: studentJoinMuted,
        fontSize: 14,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: 0.7,
      ),
    );
  }
}
