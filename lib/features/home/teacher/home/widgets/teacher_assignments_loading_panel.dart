part of '../teacher_home_tab.dart';

class _TeacherAssignmentsLoadingPanel extends StatelessWidget {
  const _TeacherAssignmentsLoadingPanel({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _TeacherSkeletonCarousel(
      scale: scale,
      itemWidth: 178 * scale,
      itemHeight: 164 * scale,
      itemCount: 2,
      builder: (context) => _TeacherAssignmentSkeletonCard(scale: scale),
    );
  }
}
