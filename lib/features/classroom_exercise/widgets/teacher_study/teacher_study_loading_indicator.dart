import 'package:numi/core/theme/app_colors.dart';

import 'package:flutter/material.dart';

class TeacherStudyLoadingIndicator extends StatelessWidget {
  const TeacherStudyLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 36),
      child: Center(child: CircularProgressIndicator(color: AppColors.teal520)),
    );
  }
}
