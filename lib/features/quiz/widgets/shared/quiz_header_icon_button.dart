import 'package:flutter/material.dart';

class QuizHeaderIconButton extends StatelessWidget {
  const QuizHeaderIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.scale,
    required this.onTap,
    this.size = 34,
    this.iconSize = 22,
    this.borderRadius,
    this.circle = false,
  });

  final IconData icon;
  final Color color;
  final double scale;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final double? borderRadius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? size / 2;
    final shape = circle ? const CircleBorder() : null;
    final border = BorderRadius.circular(radius * scale);

    return Material(
      color: Colors.transparent,
      shape: shape,
      borderRadius: circle ? null : border,
      child: InkWell(
        onTap: onTap,
        customBorder: circle ? const CircleBorder() : null,
        borderRadius: circle ? null : border,
        child: SizedBox(
          width: size * scale,
          height: size * scale,
          child: Icon(icon, color: color, size: iconSize * scale),
        ),
      ),
    );
  }
}
