part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherClassSkeletonCard extends StatelessWidget {
  const _TeacherClassSkeletonCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _TeacherSkeletonCard(
      scale: scale,
      padding: EdgeInsets.all(12 * scale),
      child: Column(
        children: [
          _TeacherSkeletonBlock(
            width: 84 * scale,
            height: 56 * scale,
            radius: 16 * scale,
          ),
          SizedBox(height: 8 * scale),
          _TeacherSkeletonBlock(
            width: 72 * scale,
            height: 16 * scale,
            radius: 8 * scale,
          ),
          SizedBox(height: 8 * scale),
          Divider(color: const Color(0x1AC4C6D2), height: 4 * scale),
          _TeacherSkeletonBlock(
            width: 88 * scale,
            height: 12 * scale,
            radius: 8 * scale,
          ),
          SizedBox(height: 5 * scale),
          _TeacherSkeletonBlock(
            width: 69 * scale,
            height: 14 * scale,
            radius: 5 * scale,
            color: _teacherTeal.withValues(alpha: 0.20),
          ),
        ],
      ),
    );
  }
}
