part of '../../practice_tab.dart';

int? _profileSemesterId(StudentProfile profile) =>
    profile.semester?.semesterId ?? profile.semester?.id ?? profile.semesterId;
