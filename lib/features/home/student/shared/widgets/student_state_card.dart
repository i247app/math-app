import 'package:flutter/material.dart';
import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/home/widgets/home_visual_constants.dart';

class StudentStateCard extends StatelessWidget {
  const StudentStateCard({
    super.key,
    required this.titleKey,
    required this.messageKey,
  });

  final String titleKey;
  final String messageKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF2F8),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              studentParentHomeClassThumbAsset,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.getText(titleKey),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.getText(messageKey),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF002B6A).withValues(alpha: 0.6),
              fontSize: FontSize.caption * 0.85,
              fontWeight: FontWeight.w900,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
