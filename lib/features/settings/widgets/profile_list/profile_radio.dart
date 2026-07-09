import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileRadio extends StatelessWidget {
  const ProfileRadio({super.key, required this.isActive, required this.scale});

  final bool isActive;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 28 * scale;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? AppColors.tealIcon : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 3 * scale),
      ),
    );
  }
}
