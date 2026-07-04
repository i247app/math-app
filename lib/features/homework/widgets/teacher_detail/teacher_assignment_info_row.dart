part of '../../presentation/teacher_homework_screen.dart';

class _TeacherAssignmentInfoRow extends StatelessWidget {
  const _TeacherAssignmentInfoRow(this.row);

  final _TeacherAssignmentLabeledValue row;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: GoogleFonts.andika(
          color: const Color(0xFF444650),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 24 / 14,
        ),
        children: [
          TextSpan(
            text: '${row.label}: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: row.value),
        ],
      ),
    );
  }
}
