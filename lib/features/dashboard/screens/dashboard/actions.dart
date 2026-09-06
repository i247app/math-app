part of '../dashboard_screen.dart';

extension _DashboardActions on _DashboardScreenState {
  void _selectTab(RoleTabCubit cubit, int index) {
    _tabPerformanceMonitor.beginTabSwitch(
      role: widget.activeRole.name,
      fromTab: cubit.state.activeTab,
      toTab: index,
    );
    cubit.selectTab(index);
  }

  void _updateParentStreak(int nextCount) {
    if (_parentStreakCount == nextCount || !mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _parentStreakCount == nextCount) {
        return;
      }
      _updateState(() => _parentStreakCount = nextCount);
    });
  }

  Future<void> _openNotifications() async {
    _notificationBadgeController.markViewed();
    final shouldCreateProfile = await _dashboardNavigator.openNotifications(
      context: context,
      notificationService: _notificationService,
      showMissingChildProfileNotice:
          widget.activeRole == ProfileRole.parent &&
          studentProfiles(widget.profiles).isEmpty,
    );
    if (!mounted || shouldCreateProfile != true) {
      return;
    }
    HapticFeedback.selectionClick();
    _profileController.requestAddProfile();
    _selectTab(_roleTabCubitFor(widget.activeRole), 4);
  }

  void _handleLogout() {
    context.read<SessionDataCleaner>().clear();
    widget.onLogout();
  }

  String _displayProfileName(
    BuildContext context,
    StudentProfile? profile,
    ProfileRole role,
  ) {
    final name = profile?.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return localizedProfileRoleLabel(context, role);
  }

  Future<void> _openTeacherProfileForm() async {
    final didSave = await _dashboardNavigator.openTeacherProfile(
      context: context,
      request: TeacherProfileNavigationRequest(
        user: widget.user,
        profiles: widget.profiles,
        activeProfile: widget.activeProfile,
        profileLoadError: widget.profileLoadError,
        onLogout: _handleLogout,
        onActivateProfile: widget.onActivateProfile,
        onRefreshProfiles: widget.onRefreshProfiles,
      ),
    );

    if (didSave) {
      await widget.onRefreshProfiles();
    }
  }
}
