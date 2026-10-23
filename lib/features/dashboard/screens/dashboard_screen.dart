import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/features/dashboard/models/dashboard_tab_id.dart';
import 'package:numi/features/dashboard/models/dashboard_tab_args.dart';
import 'package:numi/core/debug/home_tab_performance_monitor.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/core/notifications/notification_service.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/profile/helpers/profile_display_helpers.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/notifications/controllers/notification_badge_controller.dart';
import 'package:numi/features/notifications/data/notification_list_service.dart';
import 'package:numi/features/home/helpers/parent_home_helpers.dart';
import 'package:numi/features/home/widgets/teacher/teacher_home_skeleton.dart';
import 'package:numi/features/home/widgets/parent/parent_home_skeleton.dart';
import 'package:numi/features/dashboard/controllers/dashboard_profile_controller.dart';
import 'package:numi/features/dashboard/navigation/dashboard_tab_factory.dart';
import 'package:numi/features/dashboard/navigation/dashboard_navigator.dart';
import 'package:numi/features/dashboard/navigation/dashboard_tab_order.dart';
import 'package:numi/features/dashboard/controllers/role_tab_cubit.dart';
import 'package:numi/features/dashboard/widgets/layouts/role_tab_host.dart';
import 'package:numi/features/dashboard/controllers/parent_role_tab_cubit.dart';
import 'package:numi/features/dashboard/controllers/student_role_tab_cubit.dart';
import 'package:numi/features/dashboard/controllers/teacher_role_tab_cubit.dart';
import 'package:numi/features/dashboard/widgets/dashboard_background.dart';
import 'package:numi/features/dashboard/widgets/dashboard_bottom_navigation.dart';
import 'package:numi/features/dashboard/widgets/dashboard_header_bar.dart';
import 'package:numi/features/dashboard/widgets/dashboard_profile_menu.dart';
import 'package:numi/features/dashboard/widgets/dashboard_session_skeleton.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/exam/data/exam_service.dart';

part 'dashboard/actions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.activeRole,
    required this.profileLoadError,
    this.isResolvingProfile = false,
    required this.onRefreshProfiles,
    required this.onActivateProfile,
    required this.onBack,
    required this.onLogout,
    this.showChildProfileDialogOnStart = false,
    this.onChildProfileDialogShown,
    this._gradeService,
    this._classroomService,
    this._assignmentService,
    this._examService,
    this._notificationService,
    this._notificationMessages,
  });

  final LoginUser? user;
  final List<UserProfile> profiles;
  final UserProfile? activeProfile;
  final ProfileRole activeRole;
  final String? profileLoadError;
  final bool isResolvingProfile;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(UserProfile profile) onActivateProfile;
  final VoidCallback onBack;
  final VoidCallback onLogout;
  final bool showChildProfileDialogOnStart;
  final VoidCallback? onChildProfileDialogShown;
  final GradeService? _gradeService;
  final ClassroomService? _classroomService;
  final ClassroomExerciseService? _assignmentService;
  final ExamService? _examService;
  final NotificationListService? _notificationService;
  final Stream<Object?>? _notificationMessages;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ClassroomService _classroomService =
      widget._classroomService ?? context.read<ClassroomService>();
  late final ClassroomExerciseService _assignmentService =
      widget._assignmentService ?? context.read<ClassroomExerciseService>();
  late final ExamService _examService =
      widget._examService ?? context.read<ExamService>();
  late final NotificationListService _notificationService =
      widget._notificationService ?? context.read<NotificationListService>();
  late final DashboardTabFactory _tabFactory = context
      .read<DashboardTabFactory>();
  late final DashboardNavigator _dashboardNavigator = context
      .read<DashboardNavigator>();
  late final NotificationBadgeController _notificationBadgeController =
      NotificationBadgeController(
        service: _notificationService,
        incomingMessages:
            widget._notificationMessages ?? NotificationService.messages,
      );
  final ParentRoleTabCubit _parentTabCubit = ParentRoleTabCubit();
  final StudentRoleTabCubit _studentTabCubit = StudentRoleTabCubit();
  final TeacherRoleTabCubit _teacherTabCubit = TeacherRoleTabCubit();
  late final DashboardProfileController _profileController =
      DashboardProfileController(
        gradeService: widget._gradeService ?? context.read<GradeService>(),
      );
  final HomeTabPerformanceMonitor _tabPerformanceMonitor =
      HomeTabPerformanceMonitor();
  final ValueNotifier<double?> _tabSwipePosition = ValueNotifier(null);
  int _parentStreakCount = 1;

  @override
  void initState() {
    super.initState();
    _profileController.prefetchGrades(widget.user?.id);
    _notificationBadgeController.start();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.id != widget.user?.id) {
      _profileController.invalidateGrades();
      _profileController.prefetchGrades(widget.user?.id);
    }
    if (oldWidget.activeRole != widget.activeRole) {
      _tabSwipePosition.value = null;
      final oldTab = _roleTabCubitFor(oldWidget.activeRole).state.activeTab;
      final targetCubit = _roleTabCubitFor(widget.activeRole);
      _selectTab(
        targetCubit,
        dashboardTabAfterRoleChange(
          toRole: widget.activeRole,
          currentTab: oldTab,
        ),
      );
    }
  }

  @override
  void dispose() {
    _profileController.dispose();
    _parentTabCubit.close();
    _studentTabCubit.close();
    _teacherTabCubit.close();
    _tabPerformanceMonitor.dispose();
    _tabSwipePosition.dispose();
    _notificationBadgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleTabCubit = _roleTabCubitFor(widget.activeRole);
    return ListenableBuilder(
      listenable: Listenable.merge([
        _profileController,
        _notificationBadgeController,
      ]),
      builder: (context, _) {
        final profileState = _profileController.state;
        return BlocBuilder<RoleTabCubit, RoleTabState>(
          bloc: roleTabCubit,
          builder: (context, navigation) {
            final safePadding = MediaQuery.paddingOf(context);
            final topInset = safePadding.top;
            final bottomInset = safePadding.bottom;
            final studentName = compactProfileName(
              _displayProfileName(
                context,
                widget.activeProfile,
                widget.activeRole,
              ),
            );
            final hasMissingChildProfileNotice =
                widget.activeRole == ProfileRole.parent &&
                studentProfiles(widget.profiles).isEmpty;

            final navHeight = 88 + bottomInset;
            final headerHeight = 64 + topInset;
            final showHeader =
                widget.activeRole != ProfileRole.teacher &&
                navigation.activeTab == DashboardTabId.home;
            final switchableProfiles = widget.profiles
                .where(
                  (profile) =>
                      profileStableId(profile) !=
                      profileStableId(widget.activeProfile),
                )
                .toList(growable: false);
            final isMenuOpen = profileState.isMenuOpen;
            final homeHeader = showHeader
                ? RepaintBoundary(
                    child: DashboardHeaderBar(
                      topInset: topInset,
                      name: studentName,
                      profile: widget.activeProfile,
                      role: widget.activeRole,
                      canSwitchProfile: switchableProfiles.isNotEmpty,
                      isProfileMenuOpen: isMenuOpen,
                      parentStreakCount: _parentStreakCount,
                      onNotificationTap: _openNotifications,
                      hasUnreadNotifications:
                          _notificationBadgeController.hasUnread ||
                          hasMissingChildProfileNotice,
                      onProfileTap: switchableProfiles.isEmpty
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              _profileController.toggleMenu();
                            },
                    ),
                  )
                : null;
            final sessionLoadingContent = switch ((
              navigation.activeTab,
              widget.activeRole,
            )) {
              (DashboardTabId.home, ProfileRole.teacher) => TeacherHomeSkeleton(
                profile: widget.activeProfile,
                bottomPadding: navHeight + 14,
                onNotificationTap: _openNotifications,
                hasUnreadNotifications: _notificationBadgeController.hasUnread,
              ),
              (DashboardTabId.home, ProfileRole.parent) => ParentHomeSkeleton(
                bottomPadding: navHeight + 14,
                homeHeader: homeHeader,
              ),
              _ => DashboardSessionSkeleton(
                topPadding: showHeader ? headerHeight : topInset,
                bottomPadding: navHeight + 14,
              ),
            };
            return Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(
                  child: RepaintBoundary(child: DashboardBackground()),
                ),
                Positioned.fill(
                  child: widget.isResolvingProfile
                      ? sessionLoadingContent
                      : RoleTabHost(
                          tabFactory: _tabFactory,
                          profileResetSignal: profileState.profileResetSignal,
                          activeRole: widget.activeRole,
                          onSwipeToTab: (tab) {
                            HapticFeedback.selectionClick();
                            _selectTab(roleTabCubit, tab);
                          },
                          onSwipePositionChanged: (position) {
                            _tabSwipePosition.value = position;
                          },
                          onSwipeInteractionEnded: () {
                            _tabSwipePosition.value = null;
                          },
                          args: DashboardTabArgs(
                            activeTab: navigation.activeTab,
                            isActive: true,
                            activeRefreshTick: 0,
                            session: DashboardSessionData(
                              user: widget.user,
                              profiles: widget.profiles,
                              activeProfile: widget.activeProfile,
                              profileLoadError: widget.profileLoadError,
                              initialGrades: profileState.prefetchedGrades,
                            ),
                            services: DashboardTabServices(
                              gradeService:
                                  widget._gradeService ??
                                  context.read<GradeService>(),
                              classroomService: _classroomService,
                              assignmentService: _assignmentService,
                              examService: _examService,
                            ),
                            actions: DashboardTabActions(
                              onRefreshProfiles: widget.onRefreshProfiles,
                              onActivateProfile: widget.onActivateProfile,
                              onLogout: _handleLogout,
                              onProfileSaved: () {},
                              onCompleteTeacherProfile: _openTeacherProfileForm,
                              onOpenClassroomTab: () => _selectTab(
                                roleTabCubit,
                                widget.activeRole == ProfileRole.teacher
                                    ? DashboardTabId.classroom
                                    : DashboardTabId.room,
                              ),
                              onOpenGamesTab: () {
                                HapticFeedback.lightImpact();
                                _selectTab(roleTabCubit, DashboardTabId.games);
                              },
                              onOpenExercisesTab: () {
                                HapticFeedback.lightImpact();
                                _selectTab(roleTabCubit, DashboardTabId.study);
                              },
                              onOpenProfileMenu: () {
                                if (switchableProfiles.isEmpty || isMenuOpen) {
                                  return;
                                }
                                HapticFeedback.selectionClick();
                                _profileController.openMenu();
                              },
                              onParentAssessmentStateChanged: (hasAssessment) {
                                _updateParentStreak(hasAssessment ? 4 : 1);
                              },
                              onNotificationTap: _openNotifications,
                              onChildProfileDialogShown:
                                  widget.onChildProfileDialogShown,
                            ),
                            presentation: DashboardTabPresentation(
                              openAddProfileRequestId:
                                  profileState.openAddProfileRequestId,
                              bottomPadding: navHeight + 14,
                              hasUnreadNotifications:
                                  _notificationBadgeController.hasUnread ||
                                  hasMissingChildProfileNotice,
                              showChildProfileDialogOnStart:
                                  widget.showChildProfileDialogOnStart,
                              homeHeader: homeHeader,
                            ),
                          ),
                        ),
                ),
                if (widget.isResolvingProfile &&
                    homeHeader != null &&
                    widget.activeRole != ProfileRole.parent)
                  Positioned(left: 0, right: 0, top: 0, child: homeHeader),
                if (isMenuOpen)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _profileController.closeMenu,
                    ),
                  ),
                if (showHeader && isMenuOpen && switchableProfiles.isNotEmpty)
                  Positioned(
                    left: safePadding.left + 28,
                    right: safePadding.right + 28,
                    top: headerHeight - 6,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: DashboardProfileMenu(
                        profiles: switchableProfiles,
                        onSelect: (profile) {
                          HapticFeedback.selectionClick();
                          _profileController.switchProfile(
                            profile,
                            activeProfile: widget.activeProfile,
                            onActivateProfile: widget.onActivateProfile,
                            onError: (_) {
                              if (!mounted) return;
                              context.showErrorDialog(
                                context.readText(AppKeys.profileUpdateFailed),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: RepaintBoundary(
                    child: IgnorePointer(
                      ignoring: widget.isResolvingProfile,
                      child: DashboardBottomNavigation(
                        bottomInset: bottomInset,
                        activeTab: navigation.activeTab,
                        activeRole: widget.activeRole,
                        user: widget.user,
                        swipePosition: _tabSwipePosition,
                        onTabSelected: (tab) {
                          _selectTab(roleTabCubit, tab);
                        },
                      ),
                    ),
                  ),
                ),
                // LoadingScreen overlay removed — skeleton in content
                // area provides loading feedback during profile switch.
              ],
            );
          },
        );
      },
    );
  }

  RoleTabCubit _roleTabCubitFor(ProfileRole role) {
    return switch (role) {
      ProfileRole.parent => _parentTabCubit,
      ProfileRole.student => _studentTabCubit,
      ProfileRole.teacher => _teacherTabCubit,
    };
  }

  void _updateState(VoidCallback update) => setState(update);
}
