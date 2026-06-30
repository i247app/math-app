part of '../../presentation/student_homework_screen.dart';

class _StudentHomeworkFilterChip extends StatelessWidget {
  const _StudentHomeworkFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(9999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _studentHomeworkActive : const Color(0xFFE5E8EB),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              style: GoogleFonts.andika(
                color: selected ? Colors.white : _studentHomeworkMuted,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
