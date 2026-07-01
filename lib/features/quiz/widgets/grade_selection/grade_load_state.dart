part of '../../presentation/grade_selection_screen.dart';

class _GradeLoadState extends StatelessWidget {
  const _GradeLoadState({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12 * scale,
        crossAxisSpacing: 12 * scale,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        return _GradeSkeletonCard(scale: scale);
      },
    );
  }
}
