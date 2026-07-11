part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherClassroomHeader extends StatelessWidget {
  const _TeacherClassroomHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: MediaQuery.paddingOf(context).top + 60 * scale,
      decoration: BoxDecoration(color: colors.elevatedSurface),
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        MediaQuery.paddingOf(context).top + 6 * scale,
        18 * scale,
        6 * scale,
      ),
      child: Row(
        children: [
          SizedBox(width: 40 * scale),
          Expanded(
            child: Text(
              context.getText(AppKeys.studentClassroom),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: colors.brandStrong,
                fontSize: FontSize.xxxl,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 40 * scale),
        ],
      ),
    );
  }
}
