part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherClassroomSearchField extends StatelessWidget {
  const _TeacherClassroomSearchField({
    required this.scale,
    required this.controller,
  });

  final double scale;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0xFFE2E9EC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 16 * scale),
          Icon(Icons.search, color: teacherBlue, size: 24 * scale),
          SizedBox(width: 12 * scale),
          Expanded(
            child: TextField(
              controller: controller,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              style: GoogleFonts.andika(
                color: teacherInk,
                fontSize: FontSize.normal * scale,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: context.getText(AppKeys.teacherSearchClassroomHint),
                hintStyle: GoogleFonts.andika(
                  color: teacherMuted.withValues(alpha: 0.6),
                  fontSize: FontSize.normal * scale,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          Icon(Icons.tune, color: teacherBlue, size: 24 * scale),
          SizedBox(width: 16 * scale),
        ],
      ),
    );
  }
}
