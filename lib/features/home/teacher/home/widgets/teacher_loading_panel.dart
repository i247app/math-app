part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherLoadingPanel extends StatelessWidget {
  const _TeacherLoadingPanel({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _TeacherSkeletonCarousel(
      scale: scale,
      itemWidth: 166 * scale,
      itemHeight: 176 * scale,
      itemCount: 2,
      builder: (context) => _TeacherClassSkeletonCard(scale: scale),
    );
  }
}
