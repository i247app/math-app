import 'package:numi/features/profile/models/profile_role.dart';

const learningTabIndex = 5;

const parentStudentVisibleTabs = <int>[0, learningTabIndex, 3, 4];
const teacherVisibleTabs = <int>[0, 1, 2, 3, 4];

List<int> visibleDashboardTabs(ProfileRole role) => switch (role) {
  ProfileRole.parent || ProfileRole.student => parentStudentVisibleTabs,
  ProfileRole.teacher => teacherVisibleTabs,
};

bool isForwardVisibleTabTransition(ProfileRole role, int fromTab, int toTab) {
  final tabs = visibleDashboardTabs(role);
  final fromPosition = tabs.indexOf(fromTab);
  final toPosition = tabs.indexOf(toTab);
  if (fromPosition < 0 || toPosition < 0) return toTab > fromTab;
  return toPosition > fromPosition;
}

int? adjacentVisibleTab(
  ProfileRole role,
  int activeTab, {
  required bool forward,
}) {
  final tabs = visibleDashboardTabs(role);
  final position = tabs.indexOf(activeTab);
  if (position < 0) return null;
  final neighbor = position + (forward ? 1 : -1);
  return neighbor >= 0 && neighbor < tabs.length ? tabs[neighbor] : null;
}
