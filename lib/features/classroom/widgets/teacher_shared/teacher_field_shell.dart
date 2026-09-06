import 'package:flutter/material.dart';

import 'package:numi/core/theme/font_size.dart';

class TeacherFieldShell extends StatelessWidget {
  const TeacherFieldShell({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF564148),
              fontSize: FontSize.small,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              height: 1.2,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
