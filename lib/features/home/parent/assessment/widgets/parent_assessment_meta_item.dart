import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

class ParentAssessmentMetaItem extends StatelessWidget {
  const ParentAssessmentMetaItem({
    super.key,
    required this.icon,
    required this.label,
    required this.scale,
  });

  final IconData icon;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF5D4A54), size: 18 * scale),
        SizedBox(width: 5 * scale),
        Text(
          label,
          maxLines: 1,
          style: TextStyle(
            color: const Color(0xFF5D4A54),
            fontSize: FontSize.caption * scale,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
