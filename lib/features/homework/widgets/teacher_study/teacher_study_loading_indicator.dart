import 'package:numi/core/theme/app_colors.dart';

import 'package:flutter/material.dart';

class TeacherStudyLoadingIndicator extends StatelessWidget {
  const TeacherStudyLoadingIndicator({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 36 * scale),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.teal520),
      ),
    );
  }
}
