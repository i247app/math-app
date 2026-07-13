import 'package:flutter/material.dart';

class ProfileActionButton extends StatelessWidget {
  const ProfileActionButton({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.onTap,
  });

  final Widget child;
  final Color backgroundColor;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: SizedBox(
          width: width,
          height: height,
          child: Center(child: child),
        ),
      ),
    );
  }
}
