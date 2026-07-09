import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ParentTaskIconBox extends StatelessWidget {
  const ParentTaskIconBox({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.asset,
  });

  final IconData icon;
  final String? asset;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(11),
      ),
      child: asset == null
          ? Icon(icon, color: color, size: 24)
          : Center(
              child: SvgPicture.asset(
                asset!,
                width: 25,
                height: 25,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
    );
  }
}