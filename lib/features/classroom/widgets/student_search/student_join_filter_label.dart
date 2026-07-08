import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class StudentJoinFilterLabel extends StatelessWidget {
  const StudentJoinFilterLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 14,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: 0.7,
      ),
    );
  }
}
