import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

class ParentAssessmentMetaItem extends StatelessWidget {
  const ParentAssessmentMetaItem({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        Icon(icon, color: const Color(0xFF5D4A54), size: 18),
        Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            color: Color(0xFF5D4A54),
            fontSize: FontSize.caption,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
