import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParentRoomStatusIcon extends StatelessWidget {
  const ParentRoomStatusIcon({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
