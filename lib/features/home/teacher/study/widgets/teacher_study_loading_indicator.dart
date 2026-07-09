part of '../teacher_study_tab.dart';

class _TeacherStudyLoadingIndicator extends StatelessWidget {
  const _TeacherStudyLoadingIndicator({required this.scale});

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
