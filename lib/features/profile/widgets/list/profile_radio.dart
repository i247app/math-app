import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileRadio extends StatelessWidget {
  const ProfileRadio({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    const size = 28.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? AppColors.tealIcon : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 3),
      ),
    );
  }
}
