part of '../../presentation/grade_selection_screen.dart';

class _GradeSkeletonCard extends StatelessWidget {
  const _GradeSkeletonCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        20 * scale,
        20 * scale,
        17 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(28 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35 * scale,
            height: 35 * scale,
            decoration: BoxDecoration(
              color: _gradeTeal.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
          const Spacer(),
          Container(
            width: 72 * scale,
            height: 15 * scale,
            decoration: BoxDecoration(
              color: _gradeInk.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}
