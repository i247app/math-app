part of '../../presentation/teacher_homework_screen.dart';

class _CreateHomeworkSubmitButton extends StatelessWidget {
  const _CreateHomeworkSubmitButton({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      height: 48,
      child: FilledButton(
        onPressed: isLoading ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: teacherTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.getText(AppKeys.teacherCreate).toUpperCase(),
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 16 / 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 5),
                  SvgPicture.asset(
                    'assets/images/teacher_homework_create_arrow.svg',
                    width: 14,
                    height: 14,
                  ),
                ],
              ),
      ),
    );
  }
}
