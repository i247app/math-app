part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherAssignmentSkeletonCard extends StatelessWidget {
  const _TeacherAssignmentSkeletonCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _TeacherSkeletonCard(
      scale: scale,
      padding: EdgeInsets.all(18 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TeacherSkeletonBlock(
            width: 58 * scale,
            height: 42 * scale,
            radius: 12 * scale,
          ),
          const Spacer(),
          _TeacherSkeletonBlock(
            width: 94 * scale,
            height: 18 * scale,
            radius: 8 * scale,
          ),
          SizedBox(height: 8 * scale),
          _TeacherSkeletonBlock(
            width: 126 * scale,
            height: 13 * scale,
            radius: 8 * scale,
          ),
        ],
      ),
    );
  }
}
