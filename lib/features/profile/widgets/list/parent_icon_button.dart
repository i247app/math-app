import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ParentIconButton extends StatelessWidget {
  const ParentIconButton({
    super.key,
    required this.assetPath,
    required this.backgroundColor,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  final String assetPath;
  final Color backgroundColor;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10 * (size / 42)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10 * (size / 42)),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SvgPicture.asset(
              assetPath,
              width: iconSize,
              height: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
