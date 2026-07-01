part of '../../practice_tab.dart';

int? _profileProgramId(StudentProfile profile) =>
    profile.program?.programId ?? profile.program?.id ?? profile.programId;
