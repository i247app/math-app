import 'package:flutter/material.dart';

class ProfileAddButton extends StatelessWidget {
  const ProfileAddButton({super.key, required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFF8A3D),
      elevation: 4,
      shadowColor: const Color(0xFFFF8A3D).withValues(alpha: 0.20),
      borderRadius: BorderRadius.circular(12 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * scale),
        child: SizedBox(
          width: 48 * scale,
          height: 34 * scale,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 24 * scale),
        ),
      ),
    );
  }
}
