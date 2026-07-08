part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherClassDetailCodeChip extends StatelessWidget {
  const _TeacherClassDetailCodeChip({
    required this.scale,
    required this.code,
    required this.onCopy,
  });

  final double scale;
  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27 * scale,
      constraints: BoxConstraints(minWidth: 114 * scale, maxWidth: 190 * scale),
      padding: EdgeInsets.symmetric(horizontal: 17 * scale),
      decoration: BoxDecoration(
        color: AppColors.teacherMint,
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                code,
                maxLines: 1,
                style: GoogleFonts.andika(
                  color: const Color(0xFF1E3A5F),
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w700,
                  height: 1.8,
                ),
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(8 * scale),
            child: Padding(
              padding: EdgeInsets.all(2 * scale),
              child: SvgPicture.asset(
                'assets/images/teacher_class_link_copy.svg',
                width: 20 * scale,
                height: 20 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
