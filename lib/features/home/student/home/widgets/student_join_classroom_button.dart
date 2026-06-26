part of '../../../home_screen.dart';

class _StudentJoinClassroomButton extends StatelessWidget {
  const _StudentJoinClassroomButton({
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFF7B54),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 11 * scale,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 18 * scale),
              SizedBox(width: 6 * scale),
              Text(
                context.getText(AppKeys.studentJoinNewClassroom),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: FontSize.caption * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
