import 'package:flutter/material.dart';

import 'package:numi/shared/widgets/app_retry_panel.dart';

class TeacherFullScreenError extends StatelessWidget {
  const TeacherFullScreenError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppRetryPanel(message: message, onRetry: onRetry),
      ),
    );
  }
}
