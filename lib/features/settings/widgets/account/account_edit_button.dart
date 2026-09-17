import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AccountEditButton extends StatelessWidget {
  const AccountEditButton({
    super.key,
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Material(
        color: const Color(0xFFF7FBFD),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.tealIcon, width: 1.2),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: AppColors.tealIcon,
              size: 19,
            ),
          ),
        ),
      ),
    );
  }
}
