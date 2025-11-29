import 'package:flutter/material.dart';

class CurvedHeaderBackground extends StatelessWidget {
  const CurvedHeaderBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        height: 300,
        color: const Color(0xFFFAFAC8), // Màu vàng nhạt
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 100,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
