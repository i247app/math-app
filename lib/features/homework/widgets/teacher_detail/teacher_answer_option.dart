part of '../../presentation/teacher_homework_screen.dart';

class _TeacherAnswerOption extends StatelessWidget {
  const _TeacherAnswerOption({
    required this.letter,
    required this.text,
    this.selected = false,
  });

  final String letter;
  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final letterBg = selected
        ? const Color(0xFFCDF4F4)
        : const Color(0xFFFFDBD1);
    final letterColor = selected ? const Color(0xFF1E6467) : teacherCoral;

    return Container(
      height: 50,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF9FFFF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? const Color(0xFF529C9F)
              : const Color(0xFFC4C6D2).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: letterBg, shape: BoxShape.circle),
            child: Text(
              letter,
              style: GoogleFonts.andika(
                color: letterColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: teacherInk,
                fontSize: 16,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                height: 24 / 16,
              ),
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 8),
            SvgPicture.asset(
              'assets/images/teacher_homework_detail_check.svg',
              width: 20,
              height: 20,
            ),
          ],
        ],
      ),
    );
  }
}
