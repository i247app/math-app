import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

class ParentRoomDetailMeta extends StatelessWidget {
  const ParentRoomDetailMeta({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 9,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4B5563)),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF121B42),
              fontSize: FontSize.small,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
