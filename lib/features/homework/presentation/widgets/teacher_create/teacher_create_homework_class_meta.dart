import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateHomeworkClassMeta extends StatelessWidget {
  const CreateHomeworkClassMeta({
    super.key,
    required this.iconAsset,
    required this.label,
  });

  final String iconAsset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Image.asset(
          iconAsset,
          width: 18,
          height: 18,
          opacity: const AlwaysStoppedAnimation<double>(0.7),
        ),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: AppColors.navy900,
              fontSize: FontSize.small,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
            ),
          ),
        ),
      ],
    );
  }
}
