part of '../../../home_screen.dart';

class _StudentEmptyPanel extends StatelessWidget {
  const _StudentEmptyPanel({
    required this.scale,
    required this.icon,
    required this.title,
    required this.message,
  });

  final double scale;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _StudentMessagePanel(
      scale: scale,
      icon: icon,
      title: title,
      message: message,
    );
  }
}
