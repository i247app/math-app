import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

class StudentJoinFilterLabel extends StatelessWidget {
  const StudentJoinFilterLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: FontSize.small,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: 0.7,
      ),
    );
  }
}
