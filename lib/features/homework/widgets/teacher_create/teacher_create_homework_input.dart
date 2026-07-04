part of '../../presentation/teacher_homework_screen.dart';

class _CreateHomeworkInput extends StatelessWidget {
  const _CreateHomeworkInput({
    required this.controller,
    required this.hintKey,
    required this.height,
    this.radius = 16,
    this.maxLines = 1,
    this.textAlignVertical = TextAlignVertical.center,
  });

  final TextEditingController controller;
  final String hintKey;
  final double height;
  final double radius;
  final int maxLines;
  final TextAlignVertical textAlignVertical;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textAlignVertical: textAlignVertical,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        style: GoogleFonts.andika(
          color: teacherInk,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: context.getText(hintKey),
          hintStyle: GoogleFonts.andika(
            color: teacherInk.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: Color(0xFFDDE4E6), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: teacherTeal, width: 2),
          ),
        ),
      ),
    );
  }
}
