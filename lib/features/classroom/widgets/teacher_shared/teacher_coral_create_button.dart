part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherCoralCreateButton extends StatelessWidget {
  const _TeacherCoralCreateButton({
    required this.scale,
    required this.label,
    required this.onTap,
  });

  final double scale;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4 * scale),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12 * scale),
          child: Ink(
            width: 218 * scale,
            height: 65 * scale,
            decoration: BoxDecoration(
              color: _teacherCoral,
              borderRadius: BorderRadius.circular(12 * scale),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1A000000),
                  offset: Offset(0, 4 * scale),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12 * scale),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.6, 0.6, 1],
                        colors: [
                          Colors.white.withValues(alpha: 0.20),
                          Colors.white.withValues(alpha: 0.0),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: FontSize.large * scale,
                      fontWeight: FontWeight.w900,
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
