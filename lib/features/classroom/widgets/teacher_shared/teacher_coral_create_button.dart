import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class TeacherCoralCreateButton extends StatelessWidget {
  const TeacherCoralCreateButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            width: 218,
            height: 65,
            decoration: BoxDecoration(
              color: AppColors.coralTeacher,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                const BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4)),
              ],
            ),
            child: Stack(
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
                Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: FontSize.large,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
