import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/dashboard/navigation/dashboard_navigator.dart';
import 'package:numi/features/notifications/data/notification_list_service.dart';
import 'package:numi/features/notifications/navigation/notification_route.dart';
import 'package:numi/features/settings/screens/setting_tab.dart';
import 'package:numi/features/settings/helpers/setting_page_builders.dart';
import 'package:numi/features/settings/models/setting_screen_args.dart';
import 'package:numi/features/settings/navigation/settings_depth_route.dart';

class AppDashboardNavigator implements DashboardNavigator {
  const AppDashboardNavigator();

  @override
  Future<bool?> openNotifications({
    required BuildContext context,
    required NotificationListService notificationService,
    required bool showMissingChildProfileNotice,
  }) {
    return Navigator.of(context).push<bool>(
      NotificationRoute(
        notificationService: notificationService,
        showMissingChildProfileNotice: showMissingChildProfileNotice,
      ),
    );
  }

  @override
  Future<bool> openTeacherProfile({
    required BuildContext context,
    required TeacherProfileNavigationRequest request,
  }) async {
    final profile = request.activeProfile;
    if (profile == null) {
      return false;
    }
    final didSave = await Navigator.of(context).push<bool>(
      SettingsDepthRoute<bool>(
        builder: (routeContext) => Material(
          color: routeContext.themeColors.pageBackground,
          child: SafeArea(
            child: buildPushedSettingPage(
              context: routeContext,
              args: SettingScreenArgs(
                user: request.user,
                profiles: request.profiles,
                activeProfile: request.activeProfile,
                profileLoadError: request.profileLoadError,
                onLogout: request.onLogout,
                onActivateProfile: request.onActivateProfile,
                onRefreshProfiles: request.onRefreshProfiles,
                onProfileSaved: () => Navigator.of(routeContext).pop(true),
              ),
              initialView: SettingPageView.addProfile,
              initialEditingProfile: profile,
              onProfileSaved: () => Navigator.of(routeContext).pop(true),
            ),
          ),
        ),
      ),
    );
    return didSave == true;
  }
}
