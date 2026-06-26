part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherSkeletonBlock extends StatelessWidget {
  const _TeacherSkeletonBlock({
    required this.width,
    required this.height,
    required this.radius,
    this.color = const Color(0xFFF3F7FA),
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
