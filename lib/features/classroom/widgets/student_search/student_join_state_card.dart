import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:numi_flutter/features/classroom/widgets/student_search/student_class_search_style.dart';

class StudentJoinStateCard extends StatelessWidget {
  const StudentJoinStateCard({
    super.key,
    required this.assetPath,
    this.isSvg = false,
    this.titleKey,
    this.title,
    required this.messageKey,
    this.actionLabelKey,
    this.onAction,
  });

  final String assetPath;
  final bool isSvg;
  final String? titleKey;
  final String? title;
  final String messageKey;
  final String? actionLabelKey;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E8EB)),
      ),
      child: Column(
        children: [
          isSvg
              ? SvgPicture.asset(assetPath, width: 32, height: 32)
              : Image.asset(assetPath, width: 32, height: 32),
          const SizedBox(height: 10),
          Text(
            title ?? context.getText(titleKey!),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: studentJoinBlue,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.getText(messageKey),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.grayText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          if (onAction != null && actionLabelKey != null) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(context.getText(actionLabelKey!)),
              style: OutlinedButton.styleFrom(
                foregroundColor: studentJoinDeepTeal,
                side: const BorderSide(color: studentJoinDeepTeal),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
