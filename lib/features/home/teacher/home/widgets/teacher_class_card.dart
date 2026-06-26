part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherClassCard extends StatelessWidget {
  const _TeacherClassCard({
    required this.scale,
    required this.classroom,
    required this.onTap,
  });

  final double scale;
  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = classroom.name?.trim().isNotEmpty == true
        ? classroom.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0x33C4C6D2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A002B6A),
            blurRadius: 20 * scale,
            spreadRadius: -4 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24 * scale),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(14 * scale),
            child: Column(
              children: [
                _ClassThumb(classroom: classroom, scale: scale),
                SizedBox(height: 8 * scale),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.andika(
                    color: Colors.black,
                    fontSize: FontSize.normal * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Divider(color: const Color(0x1AC4C6D2), height: 4 * scale),
                Flexible(
                  child: Text(
                    _teacherMemberSummaryText(
                      context,
                      members: classroom.displayStudentCount,
                      requests: classroom.displayPendingRequestCount,
                    ),
                    maxLines: classroom.displayPendingRequestCount > 0 ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.andika(
                      color: _teacherBlue.withValues(alpha: 0.60),
                      fontSize: FontSize.caption * 0.85 * scale,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 4 * scale),
                Container(
                  height: 16 * scale,
                  width: 69 * scale,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _teacherDeepTeal,
                    borderRadius: BorderRadius.circular(5 * scale),
                  ),
                  child: Text(
                    context.getText(AppKeys.teacherEnterClass),
                    maxLines: 1,
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: FontSize.caption * 0.85 * scale,
                      fontWeight: FontWeight.w800,
                      height: 1,
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
