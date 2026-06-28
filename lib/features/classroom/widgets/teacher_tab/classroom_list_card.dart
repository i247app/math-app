part of '../../presentation/teacher_classroom_screens.dart';

class _ClassroomListCard extends StatelessWidget {
  const _ClassroomListCard({
    required this.scale,
    required this.classroom,
    required this.onTap,
  });

  final double scale;
  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title =
        classroom.name ?? context.getText(AppKeys.teacherClassFallback);
    final code = classroom.classroomCode ?? classroom.id?.toString() ?? '--';
    final memberCount = classroom.displayStudentCount;
    final classNumber = _teacherClassNumber(classroom);
    final numberPalette = _teacherClassNumberPalette(classroom);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * scale),
          border: Border.all(color: const Color(0xFFE9EEF2)),
          boxShadow: [
            BoxShadow(
              color: _teacherBlue.withValues(alpha: 0.035),
              blurRadius: 18 * scale,
              offset: Offset(0, 5 * scale),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 18 * scale,
          vertical: 18 * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TeacherClassNumberBadge(
                  scale: scale,
                  number: classNumber,
                  palette: numberPalette,
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 4 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: _teacherBlue,
                            fontSize: 21 * scale,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: 16 * scale),
                        Text(
                          'ID: $code',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: const Color(0xFF484B56),
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * scale),
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  color: const Color(0xFF4B4E5A),
                  size: 17 * scale,
                ),
                SizedBox(width: 7 * scale),
                Flexible(
                  child: Text(
                    context.formatText(
                      AppKeys.teacherStudentCount,
                      {'count': memberCount},
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.andika(
                      color: const Color(0xFF4B4E5A),
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
