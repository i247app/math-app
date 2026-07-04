part of '../teacher_home_tab.dart';

class _TeacherAssignmentSkeletonCard extends StatelessWidget {
  const _TeacherAssignmentSkeletonCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return TeacherSkeletonCard(
      scale: scale,
      padding: EdgeInsets.all(18 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeacherSkeletonBlock(
            width: 58 * scale,
            height: 42 * scale,
            radius: 12 * scale,
          ),
          const Spacer(),
          TeacherSkeletonBlock(
            width: 94 * scale,
            height: 18 * scale,
            radius: 8 * scale,
          ),
          SizedBox(height: 8 * scale),
          TeacherSkeletonBlock(
            width: 126 * scale,
            height: 13 * scale,
            radius: 8 * scale,
          ),
        ],
      ),
    );
  }
}
