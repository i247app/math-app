import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_student_search_result_tile.dart';

class TeacherStudentSearchResultList extends StatelessWidget {
  const TeacherStudentSearchResultList({
    super.key,
    required this.scrollController,
    required this.profiles,
    required this.selectedProfileIds,
    required this.isSearching,
    required this.error,
    required this.query,
    required this.onToggle,
  });

  final ScrollController scrollController;
  final List<StudentProfile> profiles;
  final Set<int> selectedProfileIds;
  final bool isSearching;
  final String? error;
  final String query;
  final ValueChanged<StudentProfile> onToggle;

  @override
  Widget build(BuildContext context) {
    if (isSearching && profiles.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal520),
      );
    }
    if (error != null) {
      return Center(
        child: Text(
          context.getText(AppKeys.teacherSearchStudentFailed),
          textAlign: TextAlign.center,
          style: GoogleFonts.andika(
            color: AppColors.textCoolMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    if (query.isNotEmpty && profiles.isEmpty) {
      return Center(
        child: Text(
          context.getText(AppKeys.teacherNoStudentResults),
          textAlign: TextAlign.center,
          style: GoogleFonts.andika(
            color: AppColors.textCoolMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: profiles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final profile = profiles[index];
        final id = ActiveProfileSession.profileStableId(profile);
        final selected = id != null && selectedProfileIds.contains(id);
        return TeacherStudentSearchResultTile(
          profile: profile,
          selected: selected,
          onTap: () => onToggle(profile),
        );
      },
    );
  }
}
