part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherMemberAddButton extends StatelessWidget {
  const _TeacherMemberAddButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12 * scale);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Material(
        color: teacherCoral,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 82 * scale,
            height: 31 * scale,
            child: Stack(
              alignment: Alignment.center,
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
                SvgPicture.asset(
                  'assets/images/teacher_class_add.svg',
                  width: 12 * scale,
                  height: 12 * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
