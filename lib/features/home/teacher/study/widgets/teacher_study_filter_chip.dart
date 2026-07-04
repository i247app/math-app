part of '../teacher_study_tab.dart';

class _TeacherStudyFilterChip extends StatelessWidget {
  const _TeacherStudyFilterChip({
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: BoxConstraints(minWidth: 80 * scale),
          height: 43 * scale,
          padding: EdgeInsets.symmetric(horizontal: 18 * scale),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? teacherDeepTeal : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: selected
                ? null
                : Border.all(color: const Color(0xFFDDE4E6)),
            boxShadow: selected
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 3 * scale,
                      offset: Offset(0, 2 * scale),
                    ),
                  ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: selected ? Colors.white : const Color(0xFF737373),
              fontSize: FontSize.small * scale,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
