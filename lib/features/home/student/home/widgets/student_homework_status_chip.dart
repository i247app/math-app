import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

class StudentHomeworkStatusChip extends StatelessWidget {
  const StudentHomeworkStatusChip({
    super.key,
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: FontSize.caption * 0.68,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
