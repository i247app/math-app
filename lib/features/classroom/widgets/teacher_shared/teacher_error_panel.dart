part of '../../presentation/teacher_classroom_screens.dart';

class TeacherErrorPanel extends StatelessWidget {
  const TeacherErrorPanel({
    super.key,
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  final double scale;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0xFFE2E9EC)),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.andika(
              color: AppColors.textCoolMuted,
              fontSize: FontSize.caption * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12 * scale),
          TextButton(
            onPressed: onRetry,
            child: Text(context.getText(AppKeys.retry)),
          ),
        ],
      ),
    );
  }
}
