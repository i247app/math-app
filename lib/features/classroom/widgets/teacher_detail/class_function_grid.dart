part of '../../presentation/teacher_classroom_screens.dart';

class _ClassFunctionGrid extends StatelessWidget {
  const _ClassFunctionGrid({
    required this.scale,
    required this.onOpenAssignments,
    required this.onOpenAssessments,
  });

  final double scale;
  final VoidCallback onOpenAssignments;
  final VoidCallback onOpenAssessments;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10 * scale,
      mainAxisSpacing: 10 * scale,
      childAspectRatio: 148 / 90,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _ClassFunctionTile(
          scale: scale,
          iconAsset: 'assets/images/classroom_homework.png',
          label: context.getText(AppKeys.teacherAssignments),
          onTap: onOpenAssignments,
        ),
        _ClassFunctionTile(
          scale: scale,
          iconAsset: 'assets/images/teacher_class_assignment.png',
          label: context.getText(AppKeys.teacherAssessments),
          onTap: onOpenAssessments,
        ),
        _ClassFunctionTile(scale: scale),
        _ClassFunctionTile(scale: scale),
      ],
    );
  }
}
