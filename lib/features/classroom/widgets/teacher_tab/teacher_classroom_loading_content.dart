part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherClassroomLoadingContent extends StatelessWidget {
  const _TeacherClassroomLoadingContent({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _TeacherSkeletonBlock(
            width: 90 * scale,
            height: 36 * scale,
            radius: 12 * scale,
            color: _teacherCoral.withValues(alpha: 0.18),
          ),
        ),
        SizedBox(height: 16 * scale),
        _TeacherSkeletonCard(
          scale: scale,
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          child: SizedBox(
            height: 48 * scale,
            child: Row(
              children: [
                _TeacherSkeletonBlock(
                  width: 24 * scale,
                  height: 24 * scale,
                  radius: 12 * scale,
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: _TeacherSkeletonBlock(
                    width: double.infinity,
                    height: 14 * scale,
                    radius: 7 * scale,
                  ),
                ),
                SizedBox(width: 16 * scale),
                _TeacherSkeletonBlock(
                  width: 24 * scale,
                  height: 24 * scale,
                  radius: 12 * scale,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24 * scale),
        for (var index = 0; index < 3; index++) ...[
          _TeacherClassroomSkeletonCard(scale: scale),
          if (index != 2) SizedBox(height: 16 * scale),
        ],
      ],
    );
  }
}
