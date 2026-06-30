part of '../../../classroom/presentation/teacher_classroom_screens.dart';

class _CreateHomeworkLabel extends StatelessWidget {
  const _CreateHomeworkLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.andika(
        color: const Color(0xFF564148),
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 20 / 14,
      ),
    );
  }
}
