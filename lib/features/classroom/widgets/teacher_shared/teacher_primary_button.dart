import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class TeacherPrimaryButton extends StatelessWidget {
  const TeacherPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final double width;
  final double height;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: onPressed == null
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: onPressed == null
                ? AppColors.teal520.withValues(alpha: 0.45)
                : AppColors.teal520,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: FontSize.large,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  Icon(icon, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
