import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

// ignore: unused_element
class _ParentRoomSectionTitle extends StatelessWidget {
  const _ParentRoomSectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 9,
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF1FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF3265E6), size: 18),
        ),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF202328),
              fontSize: FontSize.large,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
