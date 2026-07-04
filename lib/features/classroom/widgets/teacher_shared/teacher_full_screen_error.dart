part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherFullScreenError extends StatelessWidget {
  const _TeacherFullScreenError({
    required this.message,
    required this.onRetry,
    required this.scale,
  });

  final String message;
  final VoidCallback onRetry;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: TeacherErrorPanel(
          scale: scale,
          message: message,
          onRetry: onRetry,
        ),
      ),
    );
  }
}
