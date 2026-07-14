part of 'package:numi/features/classroom/presentation/screens/teacher_classroom_screens.dart';

class _TeacherSendInviteButton extends StatelessWidget {
  const _TeacherSendInviteButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coralTeacher,
          disabledBackgroundColor: const Color(0xFFE5E7EB),
          foregroundColor: Colors.white,
          disabledForegroundColor: AppColors.textCoolMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          context.getText(AppKeys.teacherSendInviteRequest),
          style: GoogleFonts.andika(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
