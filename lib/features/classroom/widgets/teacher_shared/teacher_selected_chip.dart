part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherSelectedChip extends StatelessWidget {
  const _TeacherSelectedChip({
    required this.label,
    required this.scale,
    required this.onDeleted,
  });

  final String label;
  final double scale;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 9 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAD7BE),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 118 * scale),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: AppColors.textInkDark,
                fontSize: FontSize.caption * scale,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          InkWell(
            onTap: onDeleted,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: EdgeInsets.all(2 * scale),
              child: Icon(
                Icons.close_rounded,
                color: AppColors.textInkDark.withValues(alpha: 0.45),
                size: 14 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
