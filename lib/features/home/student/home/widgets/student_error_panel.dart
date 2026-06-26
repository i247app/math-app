part of '../../../home_screen.dart';

class _StudentErrorPanel extends StatelessWidget {
  const _StudentErrorPanel({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  final double scale;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _StudentMessagePanel(
      scale: scale,
      icon: Icons.wifi_off_rounded,
      title: message,
      message: context.getText(AppKeys.retry),
      actionLabel: context.getText(AppKeys.retryUpper),
      onAction: onRetry,
    );
  }
}
