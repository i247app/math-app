import 'package:flutter/widgets.dart';

import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/notifications/data/notification_list_service.dart';
import 'package:numi/features/profile/models/profile.dart';

class TeacherProfileNavigationRequest {
  const TeacherProfileNavigationRequest({
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.profileLoadError,
    required this.onLogout,
    required this.onActivateProfile,
    required this.onRefreshProfiles,
  });

  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final String? profileLoadError;
  final VoidCallback onLogout;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final Future<void> Function() onRefreshProfiles;
}

abstract interface class DashboardNavigator {
  Future<bool?> openNotifications({
    required BuildContext context,
    required NotificationListService notificationService,
    required bool showMissingChildProfileNotice,
  });

  Future<bool> openTeacherProfile({
    required BuildContext context,
    required TeacherProfileNavigationRequest request,
  });
}
