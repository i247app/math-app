import 'package:numi/features/dashboard/models/dashboard_tab_id.dart';
import 'package:numi/features/profile/models/profile_role.dart';

const _parentStudentTabs = <DashboardTabId>[
  DashboardTabId.home,
  DashboardTabId.assessment,
  DashboardTabId.room,
  DashboardTabId.games,
  DashboardTabId.settings,
  DashboardTabId.learning,
];
const _teacherTabs = <DashboardTabId>[
  DashboardTabId.home,
  DashboardTabId.classroom,
  DashboardTabId.study,
  DashboardTabId.members,
  DashboardTabId.settings,
];
const _parentStudentVisibleTabs = <DashboardTabId>[
  DashboardTabId.home,
  DashboardTabId.learning,
  DashboardTabId.games,
  DashboardTabId.settings,
];

/// Includes destinations opened by feature actions but hidden from the bar.
List<DashboardTabId> supportedDashboardTabs(ProfileRole role) => switch (role) {
  ProfileRole.parent || ProfileRole.student => _parentStudentTabs,
  ProfileRole.teacher => _teacherTabs,
};

List<DashboardTabId> visibleDashboardTabs(ProfileRole role) => switch (role) {
  ProfileRole.parent || ProfileRole.student => _parentStudentVisibleTabs,
  ProfileRole.teacher => _teacherTabs,
};

DashboardTabId dashboardTabAfterRoleChange({
  required DashboardTabId currentTab,
  required ProfileRole toRole,
}) {
  if (supportedDashboardTabs(toRole).contains(currentTab)) return currentTab;
  return switch ((toRole, currentTab)) {
    (ProfileRole.teacher, DashboardTabId.room) => DashboardTabId.classroom,
    (ProfileRole.teacher, DashboardTabId.learning) => DashboardTabId.study,
    (ProfileRole.parent || ProfileRole.student, DashboardTabId.classroom) =>
      DashboardTabId.room,
    (ProfileRole.parent || ProfileRole.student, DashboardTabId.study) =>
      DashboardTabId.learning,
    _ => DashboardTabId.home,
  };
}

bool isForwardVisibleTabTransition(
  ProfileRole role,
  DashboardTabId fromTab,
  DashboardTabId toTab,
) {
  final tabs = visibleDashboardTabs(role);
  final fromPosition = tabs.indexOf(fromTab);
  final toPosition = tabs.indexOf(toTab);
  if (fromPosition < 0 || toPosition < 0) {
    final supported = supportedDashboardTabs(role);
    return supported.indexOf(toTab) > supported.indexOf(fromTab);
  }
  return toPosition > fromPosition;
}

DashboardTabId? adjacentVisibleTab(
  ProfileRole role,
  DashboardTabId activeTab, {
  required bool forward,
}) {
  final tabs = visibleDashboardTabs(role);
  final position = tabs.indexOf(activeTab);
  if (position < 0) return null;
  final neighbor = position + (forward ? 1 : -1);
  return neighbor >= 0 && neighbor < tabs.length ? tabs[neighbor] : null;
}

/// Preserve existing widget keys; these positions never drive navigation.
String dashboardTabWidgetKeySuffix(ProfileRole role, DashboardTabId tab) =>
    supportedDashboardTabs(role).indexOf(tab).toString();
