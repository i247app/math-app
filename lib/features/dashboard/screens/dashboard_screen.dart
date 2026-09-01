import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/debug/home_tab_performance_monitor.dart';
import 'package:numi/core/data/session_data_cleaner.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/core/notifications/notification_service.dart';
import 'package:numi/features/profile/domain/models/profile_role.dart';
import 'package:numi/features/profile/application/read_models/profile_display_read_model.dart';
import 'package:numi/features/classroom/application/contracts/classroom_service.dart';
import 'package:numi/features/homework/application/contracts/classroom_exercise_service.dart';
import 'package:numi/features/notifications/application/read_models/notification_badge_controller.dart';
import 'package:numi/features/notifications/application/contracts/notification_list_service.dart';
import 'package:numi/features/home/application/read_models/parent_home_read_model.dart';
import 'package:numi/features/dashboard/application/dashboard_profile_controller.dart';
import 'package:numi/features/dashboard/application/contracts/dashboard_tab_factory.dart';
import 'package:numi/features/dashboard/application/contracts/dashboard_navigator.dart';
import 'package:numi/features/dashboard/application/role_tab_cubit.dart';
import 'package:numi/features/dashboard/layouts/role_tab_host.dart';
import 'package:numi/features/dashboard/application/parent_role_tab_cubit.dart';
import 'package:numi/features/dashboard/application/student_role_tab_cubit.dart';
import 'package:numi/features/dashboard/application/teacher_role_tab_cubit.dart';
import 'package:numi/features/dashboard/widgets/dashboard_background.dart';
import 'package:numi/features/dashboard/widgets/dashboard_bottom_navigation.dart';
import 'package:numi/features/dashboard/widgets/dashboard_header_bar.dart';
import 'package:numi/features/dashboard/widgets/dashboard_profile_menu.dart';
import 'package:numi/features/dashboard/widgets/dashboard_session_skeleton.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';
import 'package:numi/features/auth/domain/models/auth_models.dart';
import 'package:numi/features/quiz/application/contracts/quiz_service.dart';

enum _RoleTabDestination {
  home,
  classroom,
  room,
  assessment,
  practice,
  study,
  members,
  settings,
}

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
    GradeService? gradeService,
    ClassroomService? classroomService,
    ClassroomExerciseService? assignmentService,
    QuizService? quizService,
    NotificationListService? notificationService,
    Stream<Object?>? notificationMessages,
  }) : _gradeService = gradeService,
       _classroomService = classroomService,
       _assignmentService = assignmentService,
       _quizService = quizService,
       _notificationService = notificationService,
       _notificationMessages = notificationMessages;

  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final ProfileRole activeRole;
  final String? profileLoadError;
  final bool isResolvingProfile;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final VoidCallback onBack;
  final VoidCallback onLogout;
  final bool showChildProfileDialogOnStart;
  final VoidCallback? onChildProfileDialogShown;
  final GradeService? _gradeService;
  final ClassroomService? _classroomService;
  final ClassroomExerciseService? _assignmentService;
  final QuizService? _quizService;
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
  late final QuizService _quizService =
      widget._quizService ?? context.read<QuizService>();
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
  bool _returnToPracticeAfterProfileSave = false;
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
        _tabIndexAfterRoleChange(
          fromRole: oldWidget.activeRole,
          toRole: widget.activeRole,
          currentIndex: oldTab,
        ),
      );
    }
  }

  int _tabIndexAfterRoleChange({
    required ProfileRole fromRole,
    required ProfileRole toRole,
    required int currentIndex,
  }) {
    final destination = switch (fromRole) {
      ProfileRole.parent => switch (currentIndex) {
        1 => _RoleTabDestination.assessment,
        2 => _RoleTabDestination.room,
        3 => _RoleTabDestination.practice,
        4 => _RoleTabDestination.settings,
        _ => _RoleTabDestination.home,
      },
      ProfileRole.student => switch (currentIndex) {
        1 => _RoleTabDestination.assessment,
        2 => _RoleTabDestination.room,
        3 => _RoleTabDestination.practice,
        4 => _RoleTabDestination.settings,
        _ => _RoleTabDestination.home,
      },
      ProfileRole.teacher => switch (currentIndex) {
        1 => _RoleTabDestination.classroom,
        2 => _RoleTabDestination.study,
        3 => _RoleTabDestination.members,
        4 => _RoleTabDestination.settings,
        _ => _RoleTabDestination.home,
      },
    };

    return switch (toRole) {
      ProfileRole.parent => switch (destination) {
        _RoleTabDestination.assessment => 1,
        _RoleTabDestination.room || _RoleTabDestination.classroom => 2,
        _RoleTabDestination.practice => 3,
        _RoleTabDestination.settings => 4,
        _ => 0,
      },
      ProfileRole.student => switch (destination) {
        _RoleTabDestination.assessment => 1,
        _RoleTabDestination.room || _RoleTabDestination.classroom => 2,
        _RoleTabDestination.practice => 3,
        _RoleTabDestination.settings => 4,
        _ => 0,
      },
      ProfileRole.teacher => switch (destination) {
        _RoleTabDestination.classroom || _RoleTabDestination.room => 1,
        _RoleTabDestination.study => 2,
        _RoleTabDestination.members => 3,
        _RoleTabDestination.settings => 4,
        _ => 0,
      },
    };
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
            final topInset = MediaQuery.paddingOf(context).top;
            final bottomInset = MediaQuery.paddingOf(context).bottom;
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
                navigation.activeTab == 0;
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
            return Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(
                  child: RepaintBoundary(child: DashboardBackground()),
                ),
                Positioned.fill(
                  child: widget.isResolvingProfile
                      ? DashboardSessionSkeleton(
                          topPadding: showHeader ? headerHeight : topInset,
                          bottomPadding: navHeight + 14,
                        )
                      : RoleTabHost(
                          tabFactory: _tabFactory,
                          // No ValueKey — profileResetSignal drives selective
                          // data reload without recreating the widget subtree.
                          profileResetSignal: profileState.profileResetSignal,
                          activeTab: navigation.activeTab,
                          selectionRevision: navigation.selectionRevision,
                          user: widget.user,
                          profiles: widget.profiles,
                          activeProfile: widget.activeProfile,
                          activeRole: widget.activeRole,
                          profileLoadError: widget.profileLoadError,
                          onRefreshProfiles: widget.onRefreshProfiles,
                          onActivateProfile: widget.onActivateProfile,
                          initialGrades: profileState.prefetchedGrades,
                          gradeService:
                              widget._gradeService ??
                              context.read<GradeService>(),
                          classroomService: _classroomService,
                          assignmentService: _assignmentService,
                          quizService: _quizService,
                          onLogout: _handleLogout,
                          onAddProfileFromPractice: () {
                            HapticFeedback.selectionClick();
                            _profileController.requestAddProfile();
                            setState(() {
                              _returnToPracticeAfterProfileSave = true;
                            });
                            _selectTab(roleTabCubit, 4);
                          },
                          onProfileSaved: () {
                            if (!_returnToPracticeAfterProfileSave) {
                              return;
                            }
                            setState(() {
                              _returnToPracticeAfterProfileSave = false;
                            });
                            _selectTab(roleTabCubit, 3);
                          },
                          openAddProfileRequestId:
                              profileState.openAddProfileRequestId,
                          onCompleteTeacherProfile: _openTeacherProfileForm,
                          onOpenClassroomTab: () => _selectTab(
                            roleTabCubit,
                            widget.activeRole == ProfileRole.teacher ? 1 : 2,
                          ),
                          onOpenPracticeTab: () {
                            HapticFeedback.lightImpact();
                            _selectTab(
                              roleTabCubit,
                              widget.activeRole == ProfileRole.teacher ? 2 : 3,
                            );
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
                          bottomPadding: navHeight + 14,
                          hasUnreadNotifications:
                              _notificationBadgeController.hasUnread ||
                              hasMissingChildProfileNotice,
                          onNotificationTap: _openNotifications,
                          homeHeader: homeHeader,
                          showChildProfileDialogOnStart:
                              widget.showChildProfileDialogOnStart,
                          onSwipeToTab: (index) {
                            HapticFeedback.selectionClick();
                            _selectTab(roleTabCubit, index);
                          },
                          onSwipePositionChanged: (position) {
                            _tabSwipePosition.value = position;
                          },
                          onSwipeInteractionEnded: () {
                            _tabSwipePosition.value = null;
                          },
                          onChildProfileDialogShown:
                              widget.onChildProfileDialogShown,
                        ),
                ),
                if (widget.isResolvingProfile && homeHeader != null)
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
                    left: 28,
                    right: 28,
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
                        activeIndex: navigation.activeTab,
                        activeRole: widget.activeRole,
                        user: widget.user,
                        swipePosition: _tabSwipePosition,
                        onTabSelected: (index) {
                          _selectTab(roleTabCubit, index);
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
      setState(() => _parentStreakCount = nextCount);
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
