part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherHomeSectionHeaderSkeleton extends StatefulWidget {
  const _TeacherHomeSectionHeaderSkeleton({required this.scale});

  final double scale;

  @override
  State<_TeacherHomeSectionHeaderSkeleton> createState() =>
      _TeacherHomeSectionHeaderSkeletonState();
}

class _TeacherHomeSectionHeaderSkeletonState
    extends State<_TeacherHomeSectionHeaderSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    return _TeacherSkeletonShimmer(
      controller: _controller,
      child: Row(
        children: [
          _TeacherSkeletonBlock(
            width: 42 * scale,
            height: 42 * scale,
            radius: 14 * scale,
            color: _teacherTeal.withValues(alpha: 0.16),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: _TeacherSkeletonBlock(
              width: double.infinity,
              height: 22 * scale,
              radius: 10 * scale,
            ),
          ),
          SizedBox(width: 16 * scale),
          _TeacherSkeletonBlock(
            width: 82 * scale,
            height: 22 * scale,
            radius: 11 * scale,
            color: _teacherTeal.withValues(alpha: 0.14),
          ),
        ],
      ),
    );
  }
}
