import 'package:flutter/material.dart';

class ProfileAddButton extends StatelessWidget {
  const ProfileAddButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFF8A3D),
      elevation: 4,
      shadowColor: const Color(0xFFFF8A3D).withValues(alpha: 0.20),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const SizedBox(
          width: 48,
          height: 34,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
