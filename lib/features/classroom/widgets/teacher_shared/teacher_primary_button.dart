part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherPrimaryButton extends StatelessWidget {
  const _TeacherPrimaryButton({
    required this.label,
    required this.icon,
    required this.width,
    required this.height,
    required this.scale,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final double width;
  final double height;
  final double scale;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * scale),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20 * scale),
            boxShadow: onPressed == null
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 2 * scale,
                      offset: Offset(0, 4 * scale),
                    ),
                  ],
          ),
          child: Material(
            color: onPressed == null
                ? teacherTeal.withValues(alpha: 0.45)
                : teacherTeal,
            borderRadius: BorderRadius.circular(20 * scale),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: FontSize.large * scale,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Icon(icon, color: Colors.white, size: 18 * scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
