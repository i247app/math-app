part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherHomeHeroSkeleton extends StatelessWidget {
  const _TeacherHomeHeroSkeleton({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92 * scale,
      child: _TeacherSkeletonCard(
        scale: scale,
        padding: EdgeInsets.fromLTRB(
          14 * scale,
          14 * scale,
          18 * scale,
          14 * scale,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TeacherSkeletonBlock(
                    width: 148 * scale,
                    height: 20 * scale,
                    radius: 8 * scale,
                    color: _teacherTeal.withValues(alpha: 0.18),
                  ),
                  SizedBox(height: 10 * scale),
                  _TeacherSkeletonBlock(
                    width: 218 * scale,
                    height: 15 * scale,
                    radius: 8 * scale,
                  ),
                ],
              ),
            ),
            _TeacherSkeletonBlock(
              width: 64 * scale,
              height: 64 * scale,
              radius: 20 * scale,
              color: _teacherHero.withValues(alpha: 0.22),
            ),
          ],
        ),
      ),
    );
  }
}
