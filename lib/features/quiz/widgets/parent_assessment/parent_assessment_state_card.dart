import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';

class ParentAssessmentStateCard extends StatelessWidget {
  const ParentAssessmentStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.onTap,
    required this.scale,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0xFFE1E8E7)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF339395), size: 32 * scale),
          SizedBox(height: 8 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF17252B),
              fontSize: FontSize.normal * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF77859A),
              fontSize: FontSize.caption * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10 * scale),
          TextButton(
            onPressed: onTap,
            child: Text(context.getText(AppKeys.retry)),
          ),
        ],
      ),
    );
  }
}
