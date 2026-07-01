part of '../../practice_tab.dart';

int? _profileGradeId(StudentProfile profile) =>
    profile.grade?.gradeId ?? profile.grade?.id ?? profile.gradeId;
