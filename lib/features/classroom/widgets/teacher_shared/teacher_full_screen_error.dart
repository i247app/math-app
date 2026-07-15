import 'package:flutter/material.dart';

import 'package:numi/shared/widgets/app_retry_panel.dart';

class TeacherFullScreenError extends StatelessWidget {
  const TeacherFullScreenError({
    super.key,
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
        child: AppRetryPanel(scale: scale, message: message, onRetry: onRetry),
      ),
    );
  }
}
