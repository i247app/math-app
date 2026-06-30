part of '../../presentation/student_homework_result_screen.dart';

class _StudentHomeworkResultHeader extends StatelessWidget {
  const _StudentHomeworkResultHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 * scale,
      padding: EdgeInsets.only(left: 20 * scale, right: 20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _StudentHomeworkResultHeaderIconButton(
              icon: Icons.arrow_back_rounded,
              scale: scale,
              onTap: () => _closeHomeworkResult(context),
            ),
          ),
          Text(
            context.getText(AppKeys.assessmentResultTitle),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: _homeworkResultHeaderTeal,
              fontSize: 25 * scale,
              fontWeight: FontWeight.w800,
              height: 34 / 25,
              letterSpacing: -0.2 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
