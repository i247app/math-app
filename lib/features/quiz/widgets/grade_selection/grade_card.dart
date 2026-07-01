part of '../../presentation/grade_selection_screen.dart';

class _GradeCard extends StatelessWidget {
  const _GradeCard({
    required this.option,
    required this.scale,
    required this.isSelected,
    required this.onSelected,
  });

  final _GradeOption option;
  final double scale;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: option.label,
      selected: isSelected,
      button: true,
      enabled: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28 * scale),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(28 * scale),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.fromLTRB(
              20 * scale,
              20 * scale,
              20 * scale,
              17 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28 * scale),
              border: Border.all(
                color: isSelected ? _gradeTeal : Colors.transparent,
                width: 2 * scale,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? _gradeTeal.withValues(alpha: 0.16)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelected ? 16 * scale : 10 * scale,
                  offset: Offset(0, isSelected ? 7 * scale : 4 * scale),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GradeBadge(
                  option: option,
                  scale: scale,
                  isSelected: isSelected,
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    option.label,
                    maxLines: 1,
                    style: TextStyle(
                      color: _gradeInk,
                      fontSize: 17 * scale,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
