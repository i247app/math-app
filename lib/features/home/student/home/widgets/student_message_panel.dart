import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

class StudentMessagePanel extends StatelessWidget {
  const StudentMessagePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: homeTeal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: homeTeal, size: 28),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: homeDeepInk,
                fontSize: FontSize.normal,
                fontWeight: FontWeight.w900,
                height: 1.15,
                letterSpacing: 0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.grayText,
                fontSize: FontSize.caption,
                fontWeight: FontWeight.w700,
                height: 1.25,
                letterSpacing: 0,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ),
        ],
      ),
    );
  }
}
