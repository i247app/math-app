import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';

class TeacherSendingInviteOverlay extends StatelessWidget {
  const TeacherSendingInviteOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: Colors.black38,
          child: Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.teal520),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
