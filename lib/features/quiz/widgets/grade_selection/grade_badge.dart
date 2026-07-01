part of '../../presentation/grade_selection_screen.dart';

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({
    required this.option,
    required this.scale,
    required this.isSelected,
  });

  final _GradeOption option;
  final double scale;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final size = 35 * scale;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? _gradeTeal : AppColors.aquaMist,
        shape: BoxShape.circle,
      ),
      child: option.number == null
          ? Icon(
              Icons.school_rounded,
              color: isSelected ? Colors.white : _gradeTeal,
              size: 19 * scale,
            )
          : Text(
              option.number!,
              style: TextStyle(
                color: isSelected ? Colors.white : _gradeTeal,
                fontSize: 17 * scale,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0,
              ),
            ),
    );
  }
}
