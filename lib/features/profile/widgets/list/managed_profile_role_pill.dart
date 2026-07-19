import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/profile/widgets/list/profile_list_helpers.dart';

class ManagedProfileRolePill extends StatelessWidget {
  const ManagedProfileRolePill({super.key, required this.role});

  final ProfileRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEEE7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        localizedProfileRole(context, role),
        style: GoogleFonts.andika(
          color: const Color(0xFF008080),
          fontSize: FontSize.caption,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
