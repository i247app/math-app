part of 'package:numi/features/classroom/presentation/screens/teacher_classroom_screens.dart';

class _TeacherFieldShell extends StatelessWidget {
  const _TeacherFieldShell({
    required this.label,
    required this.scale,
    required this.child,
  });

  final String label;
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4 * scale, bottom: 8 * scale),
          child: Text(
            label,
            style: GoogleFonts.andika(
              color: const Color(0xFF564148),
              fontSize: FontSize.small * scale,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              height: 1.2,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
