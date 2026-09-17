import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/core/theme/app_colors.dart';
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
          style: const TextStyle(
            color: AppColors.textCoolMuted,
            fontSize: FontSize.small,
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
          style: const TextStyle(
            color: AppColors.textCoolMuted,
            fontSize: FontSize.small,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        final id = profileStableId(profile);
        final selected = id != null && selectedProfileIds.contains(id);
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == profiles.length - 1 ? 0 : 10,
          ),
          child: TeacherStudentSearchResultTile(
            profile: profile,
            selected: selected,
            onTap: () => onToggle(profile),
          ),
        );
      },
    );
  }
}
