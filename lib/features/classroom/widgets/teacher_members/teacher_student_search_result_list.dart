part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherStudentSearchResultList extends StatelessWidget {
  const _TeacherStudentSearchResultList({
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
        child: CircularProgressIndicator(color: _teacherTeal),
      );
    }
    if (error != null) {
      return Center(
        child: Text(
          context.getText(AppKeys.teacherSearchStudentFailed),
          textAlign: TextAlign.center,
          style: GoogleFonts.andika(
            color: _teacherMuted,
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
            color: _teacherMuted,
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
        return _TeacherStudentSearchResultTile(
          profile: profile,
          selected: selected,
          onTap: () => onToggle(profile),
        );
      },
    );
  }
}
