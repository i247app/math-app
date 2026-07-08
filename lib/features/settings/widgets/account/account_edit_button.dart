import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AccountEditButton extends StatelessWidget {
  const AccountEditButton({
    super.key,
    required this.enabled,
    required this.scale,
    required this.onTap,
  });

  final bool enabled;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Material(
        color: const Color(0xFFF7FBFD),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10 * scale),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10 * scale),
          child: Container(
            width: 36 * scale,
            height: 36 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10 * scale),
              border: Border.all(color: AppColors.tealIcon, width: 1.2),
            ),
            child: Icon(
              Icons.edit_rounded,
              color: AppColors.tealIcon,
              size: 19 * scale,
            ),
          ),
        ),
      ),
    );
  }
}
