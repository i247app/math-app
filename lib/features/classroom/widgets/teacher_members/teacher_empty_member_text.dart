part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherEmptyMemberText extends StatelessWidget {
  const _TeacherEmptyMemberText({required this.scale, required this.text});

  final double scale;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 18 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.andika(
          color: AppColors.textCoolMuted,
          fontSize: 14 * scale,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
    );
  }
}
