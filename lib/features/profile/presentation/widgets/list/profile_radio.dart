import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileRadio extends StatelessWidget {
  const ProfileRadio({
    super.key,
    required this.isActive,
    this.isLoading = false,
  });

  final bool isActive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    const size = 28.0;

    if (isLoading) {
      return const SizedBox.square(
        dimension: size,
        child: Padding(
          padding: EdgeInsets.all(3),
          child: CircularProgressIndicator(
            color: AppColors.tealIcon,
            strokeWidth: 2.6,
          ),
        ),
      );
    }

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
