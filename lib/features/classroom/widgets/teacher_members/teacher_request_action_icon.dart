import 'package:flutter/material.dart';

class TeacherRequestActionIcon extends StatelessWidget {
  const TeacherRequestActionIcon({
    super.key,
    required this.asset,
    required this.size,
    required this.onTap,
  });

  final String asset;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: size,
      child: Opacity(
        opacity: onTap == null ? 0.35 : 0.8,
        child: Image.asset(asset, width: size, height: size),
      ),
    );
  }
}
