import 'package:flutter/material.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/classroom/widgets/student_search/student_class_search_style.dart';

class StudentJoinRetryBanner extends StatelessWidget {
  const StudentJoinRetryBanner({
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
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4ED),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF4C7AE)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Color(0xFFA03A0F),
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF7E2F0E),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          IconButton(
            onPressed: onRetry,
            tooltip: context.getText(AppKeys.studentRetry),
            icon: const Icon(
              Icons.refresh_rounded,
              color: studentJoinDeepTeal,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
