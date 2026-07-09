import 'package:flutter/material.dart';
import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/font_size.dart';

class StudentInlineErrorPanel extends StatelessWidget {
  const StudentInlineErrorPanel({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF444650),
                fontSize: FontSize.caption,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(context.getText(AppKeys.studentRetry)),
          ),
        ],
      ),
    );
  }
}
