part of '../../presentation/grade_selection_screen.dart';

class _GradeFailureNotice extends StatelessWidget {
  const _GradeFailureNotice({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: _gradePeach.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: _gradeRust.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: _gradeRust, size: 20 * scale),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              context.getText(AppKeys.generateTestFailed),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _gradeRust,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w900,
                height: 1.25,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
