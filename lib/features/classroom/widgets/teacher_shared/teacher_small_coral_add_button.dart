import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/core/theme/app_colors.dart';

class TeacherSmallCoralAddButton extends StatelessWidget {
  const TeacherSmallCoralAddButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            const BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4)),
          ],
        ),
        child: Material(
          color: AppColors.coralTeacher,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 91,
              height: 31,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0, 0.6, 0.6, 1],
                          colors: [
                            Colors.white.withValues(alpha: 0.20),
                            Colors.white.withValues(alpha: 0.0),
                            Colors.transparent,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/images/teacher_class_add.svg',
                    width: 12,
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
