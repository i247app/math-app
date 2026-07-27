import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/debug/home_tab_performance_monitor.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/profile/helpers/profile_display_helpers.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/home/data/cache/home_profile_cache.dart';
import 'package:numi/features/dashboard/application/dashboard_profile_controller.dart';
import 'package:numi/features/dashboard/application/role_tab_cubit.dart';
import 'package:numi/features/dashboard/layouts/role_tab_host.dart';
import 'package:numi/features/dashboard/application/parent_role_tab_cubit.dart';
import 'package:numi/features/dashboard/application/student_role_tab_cubit.dart';
import 'package:numi/features/dashboard/application/teacher_role_tab_cubit.dart';
import 'package:numi/features/dashboard/widgets/dashboard_background.dart';
import 'package:numi/features/dashboard/widgets/dashboard_bottom_navigation.dart';
import 'package:numi/features/dashboard/widgets/dashboard_header_bar.dart';
import 'package:numi/features/dashboard/widgets/dashboard_profile_menu.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';
import 'package:numi/features/settings/helpers/setting_page_builders.dart';
import 'package:numi/features/settings/application/setting_tab.dart';
import 'package:numi/features/settings/models/setting_screen_args.dart';
import 'package:numi/features/settings/navigation/settings_depth_route.dart';

enum _RoleTabDestination {
  home,
  classroom,
  room,
  assessment,
  practice,
  history,
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
    required this.onRefreshProfiles,
    required this.onActivateProfile,
    required this.onBack,
    required this.onLogout,
    GradeService? gradeService,
    ClassroomService? classroomService,
    ClassroomExerciseService? assignmentService,
    QuizService? quizService,
  }) : _gradeService = gradeService,
       _classroomService = classroomService,
       _assignmentService = assignmentService,
       _quizService = quizService;

  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final ProfileRole activeRole;
  final String? profileLoadError;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final VoidCallback onBack;
  final VoidCallback onLogout;
  final GradeService? _gradeService;
  final ClassroomService? _classroomService;
  final ClassroomExerciseService? _assignmentService;
  final QuizService? _quizService;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();
  late final ClassroomExerciseService _assignmentService =
      widget._assignmentService ?? ClassroomExerciseApi();
  late final QuizService _quizService = widget._quizService ?? QuizApi();
  final ParentRoleTabCubit _parentTabCubit = ParentRoleTabCubit();
  final StudentRoleTabCubit _studentTabCubit = StudentRoleTabCubit();
  final TeacherRoleTabCubit _teacherTabCubit = TeacherRoleTabCubit();
  late final AnimationController _parentHomeEntranceController;
  late final DashboardProfileController _profileController =
      DashboardProfileController(gradeService: widget._gradeService);
  final HomeTabPerformanceMonitor _tabPerformanceMonitor =
      HomeTabPerformanceMonitor();
  bool _returnToPracticeAfterProfileSave = false;
  int _parentStreakCount = 1;

  @override
  void initState() {
    super.initState();
    _parentHomeEntranceController = AnimationController(
      vsync: this,
      duration: homeFadeInDuration,
    );
    if (widget.activeRole == ProfileRole.parent) {
      _parentHomeEntranceController.forward();
    }
    _profileController.prefetchGrades(widget.user?.id);
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldProfileId = ActiveProfileSession.profileStableId(
      oldWidget.activeProfile,
    );
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (oldWidget.user?.id != widget.user?.id) {
      _profileController.invalidateGrades();
      _profileController.prefetchGrades(widget.user?.id);
    }
    if (oldWidget.activeRole != widget.activeRole) {
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
    if (oldWidget.activeRole != widget.activeRole &&
        widget.activeRole == ProfileRole.parent) {
      _playParentHomeEntrance();
    }
    if (oldProfileId != profileId) {
      if (widget.activeRole == ProfileRole.parent) {
        _playParentHomeEntrance();
      }
    }
  }

  void _playParentHomeEntrance() {
    _parentHomeEntranceController
      ..reset()
      ..forward();
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
        1 => _RoleTabDestination.classroom,
        2 => _RoleTabDestination.practice,
        3 => _RoleTabDestination.history,
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
        _RoleTabDestination.classroom || _RoleTabDestination.room => 1,
        _RoleTabDestination.practice => 2,
        _RoleTabDestination.history => 3,
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
    _parentHomeEntranceController.dispose();
    _profileController.dispose();
    _parentTabCubit.close();
    _studentTabCubit.close();
    _teacherTabCubit.close();
    _tabPerformanceMonitor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleTabCubit = _roleTabCubitFor(widget.activeRole);
    return ListenableBuilder(
      listenable: _profileController,
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

            final navHeight = 88 + bottomInset;
            final headerHeight = 64 + topInset;
            final showHeader =
                widget.activeRole != ProfileRole.teacher &&
                navigation.activeTab == 0;
            final switchableProfiles = widget.profiles
                .where(
                  (profile) =>
                      ActiveProfileSession.profileStableId(profile) !=
                      ActiveProfileSession.profileStableId(
                        widget.activeProfile,
                      ),
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
                  child: RoleTabHost(
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
                    gradeService: widget._gradeService ?? GradeApi(),
                    classroomService: _classroomService,
                    assignmentService: _assignmentService,
                    quizService: _quizService,
                    onLogout: () {
                      HomeProfileCache.instance.invalidateAll();
                      widget.onLogout();
                    },
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
                      widget.activeRole == ProfileRole.parent ? 2 : 1,
                    ),
                    onOpenPracticeTab: () {
                      HapticFeedback.lightImpact();
                      _selectTab(
                        roleTabCubit,
                        widget.activeRole == ProfileRole.parent ? 3 : 2,
                      );
                    },
                    onOpenHistoryTab: () => _selectTab(roleTabCubit, 3),
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
                    parentHomeEntrance: _parentHomeEntranceController,
                    bottomPadding: navHeight + 14,
                    homeHeader: homeHeader,
                  ),
                ),
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
                    child: DashboardBottomNavigation(
                      bottomInset: bottomInset,
                      activeIndex: navigation.activeTab,
                      activeRole: widget.activeRole,
                      user: widget.user,
                      onTabSelected: (index) {
                        if (widget.activeRole == ProfileRole.parent &&
                            index != navigation.activeTab &&
                            index == 0) {
                          _playParentHomeEntrance();
                        }
                        _selectTab(roleTabCubit, index);
                      },
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
    final profile = widget.activeProfile;
    if (profile == null) {
      return;
    }
    final didSave = await Navigator.of(context).push<bool>(
      SettingsDepthRoute<bool>(
        builder: (routeContext) => Material(
          color: routeContext.themeColors.pageBackground,
          child: SafeArea(
            child: buildPushedSettingPage(
              context: routeContext,
              args: SettingScreenArgs(
                user: widget.user,
                profiles: widget.profiles,
                activeProfile: widget.activeProfile,
                profileLoadError: widget.profileLoadError,
                onLogout: widget.onLogout,
                onActivateProfile: widget.onActivateProfile,
                onRefreshProfiles: widget.onRefreshProfiles,
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

    if (didSave == true) {
      await widget.onRefreshProfiles();
    }
  }
}
