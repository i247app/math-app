part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherTextField extends StatelessWidget {
  const _TeacherTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.scale,
    this.maxLines = 1,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final double scale;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return _TeacherFieldShell(
      label: label,
      scale: scale,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        style: GoogleFonts.andika(
          color: teacherInk,
          fontSize: FontSize.normal * scale,
          fontWeight: FontWeight.w400,
        ),
        decoration: _teacherInputDecoration(hintText: hintText, scale: scale),
      ),
    );
  }
}
