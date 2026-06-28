part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherMemberSectionTitle extends StatelessWidget {
  const _TeacherMemberSectionTitle({
    required this.scale,
    required this.title,
  });

  final double scale;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.andika(
        color: const Color(0xFF1E3A5F),
        fontSize: 18 * scale,
        fontWeight: FontWeight.w700,
        height: 1.55,
      ),
    );
  }
}
