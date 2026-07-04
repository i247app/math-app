part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherClassroomAddButton extends StatelessWidget {
  const _TeacherClassroomAddButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 90 * scale,
          height: 36 * scale,
          decoration: BoxDecoration(
            color: teacherCoral,
            borderRadius: BorderRadius.circular(12 * scale),
          ),
          child: Icon(Icons.add, color: Colors.white, size: 24 * scale),
        ),
      ),
    );
  }
}
