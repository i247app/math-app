import 'package:numi/core/theme/app_colors.dart';

import 'package:material_ui/material_ui.dart';

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
