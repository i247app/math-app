import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/theme/app_colors.dart';

class StudentClassSectionTitle extends StatelessWidget {
  const StudentClassSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.textNavy,
        fontSize: FontSize.large,
        fontWeight: FontWeight.w700,
        height: 1.5,
      ),
    );
  }
}
