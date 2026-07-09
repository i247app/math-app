import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/profile/active_profile_session.dart';
import 'package:numi/features/profile/helpers/profile_display_helpers.dart';
import 'package:numi/features/classroom/classroom_api.dart';
import 'package:numi/features/homework/homework_api.dart';
import 'package:numi/features/home/cache/home_profile_cache.dart';
import 'package:numi/features/home/home_profile_controller.dart';
import 'package:numi/features/home/home_tab_cubit.dart';
import 'package:numi/features/home/parent/parent_dashboard.dart';
import 'package:numi/features/home/parent/parent_home_cubit.dart';
import 'package:numi/features/home/student/student_dashboard.dart';
import 'package:numi/features/home/student/student_home_cubit.dart';
import 'package:numi/features/home/teacher/teacher_dashboard.dart';
import 'package:numi/features/home/teacher/teacher_home_cubit.dart';
import 'package:numi/features/home/widgets/home_background.dart';
import 'package:numi/features/home/widgets/home_bottom_navigation.dart';
import 'package:numi/features/home/widgets/home_dashboard_args.dart';
import 'package:numi/features/home/widgets/home_header_bar.dart';
import 'package:numi/features/home/widgets/home_profile_menu.dart';
import 'package:numi/features/home/widgets/home_visual_constants.dart';
import 'package:numi/features/profile/grade_api.dart';
import 'package:numi/features/auth/otp_auth_api.dart';
import 'package:numi/features/quiz/quiz_api.dart';
import 'package:numi/features/settings/helpers/setting_page_builders.dart';
import 'package:numi/features/settings/models/setting_screen_args.dart';
import 'package:numi/features/settings/setting_tab.dart';

part 'widgets/home_role_dashboard.dart';

enum _HomeTabDestination {
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();
  late final ClassroomExerciseService _assignmentService =
      widget._assignmentService ?? ClassroomExerciseApi();
  late final QuizService _quizService = widget._quizService ?? QuizApi();
  final ParentHomeCubit _parentHomeCubit = ParentHomeCubit();
  final StudentHomeCubit _studentHomeCubit = StudentHomeCubit();
  final TeacherHomeCubit _teacherHomeCubit = TeacherHomeCubit();
  late final AnimationController _parentHomeEntranceController;
  late final HomeProfileController _profileController = HomeProfileController(
    gradeService: widget._gradeService,
  );
  bool _returnToPracticeAfterProfileSave = false;
  int _parentStreakCount = 1;

  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

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
  void didUpdateWidget(covariant HomeScreen oldWidget) {
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
      final oldTab = _homeCubitFor(oldWidget.activeRole).state.activeTab;
      final targetCubit = _homeCubitFor(widget.activeRole);
      targetCubit.selectTab(
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
        1 => _HomeTabDestination.assessment,
        2 => _HomeTabDestination.room,
        3 => _HomeTabDestination.practice,
        4 => _HomeTabDestination.settings,
        _ => _HomeTabDestination.home,
      },
      ProfileRole.student => switch (currentIndex) {
        1 => _HomeTabDestination.classroom,
        2 => _HomeTabDestination.practice,
        3 => _HomeTabDestination.history,
        4 => _HomeTabDestination.settings,
        _ => _HomeTabDestination.home,
      },
      ProfileRole.teacher => switch (currentIndex) {
        1 => _HomeTabDestination.classroom,
        2 => _HomeTabDestination.study,
        3 => _HomeTabDestination.members,
        4 => _HomeTabDestination.settings,
        _ => _HomeTabDestination.home,
      },
    };

    return switch (toRole) {
      ProfileRole.parent => switch (destination) {
        _HomeTabDestination.assessment => 1,
        _HomeTabDestination.room || _HomeTabDestination.classroom => 2,
        _HomeTabDestination.practice => 3,
        _HomeTabDestination.settings => 4,
        _ => 0,
      },
      ProfileRole.student => switch (destination) {
        _HomeTabDestination.classroom || _HomeTabDestination.room => 1,
        _HomeTabDestination.practice => 2,
        _HomeTabDestination.history => 3,
        _HomeTabDestination.settings => 4,
        _ => 0,
      },
      ProfileRole.teacher => switch (destination) {
        _HomeTabDestination.classroom || _HomeTabDestination.room => 1,
        _HomeTabDestination.study => 2,
        _HomeTabDestination.members => 3,
        _HomeTabDestination.settings => 4,
        _ => 0,
      },
    };
  }

  @override
  void dispose() {
    _parentHomeEntranceController.dispose();
    _profileController.dispose();
    _parentHomeCubit.close();
    _studentHomeCubit.close();
    _teacherHomeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeCubit = _homeCubitFor(widget.activeRole);
    return ListenableBuilder(
      listenable: _profileController,
      builder: (context, _) {
        final profileState = _profileController.state;
        return BlocBuilder<HomeTabCubit, HomeTabState>(
          bloc: homeCubit,
          builder: (context, navigation) => LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final layoutWidth = math.min(width, 430.0);
              final height = constraints.maxHeight;
              final viewportHeight = MediaQuery.sizeOf(context).height;
              final topInset = MediaQuery.paddingOf(context).top;
              final bottomInset = MediaQuery.paddingOf(context).bottom;
              final scale = math.min(
                layoutWidth / _designWidth,
                viewportHeight / _designHeight,
              );
              final studentName = compactHomeProfileName(
                _displayProfileName(
                  context,
                  widget.activeProfile,
                  widget.activeRole,
                ),
              );

              double s(double value) => value * scale;
              final navHeight = s(88) + bottomInset;
              final headerHeight = s(64) + topInset;
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
              return Center(
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Positioned.fill(child: HomeBackground()),
                      Positioned.fill(
                        child: HomeRoleDashboard(
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
                            homeCubit.selectTab(4);
                          },
                          onProfileSaved: () {
                            if (!_returnToPracticeAfterProfileSave) {
                              return;
                            }
                            setState(() {
                              _returnToPracticeAfterProfileSave = false;
                            });
                            homeCubit.selectTab(3);
                          },
                          openAddProfileRequestId:
                              profileState.openAddProfileRequestId,
                          onCompleteTeacherProfile: _openTeacherProfileForm,
                          onOpenClassroomTab: () => homeCubit.selectTab(
                            widget.activeRole == ProfileRole.parent ? 2 : 1,
                          ),
                          onOpenPracticeTab: () {
                            HapticFeedback.lightImpact();
                            homeCubit.selectTab(
                              widget.activeRole == ProfileRole.parent ? 3 : 2,
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
                          parentHomeEntrance: _parentHomeEntranceController,
                          bottomPadding: navHeight + s(14),
                          headerHeight: showHeader ? headerHeight : 0,
                          scale: scale,
                        ),
                      ),
                      if (isMenuOpen)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: _profileController.closeMenu,
                          ),
                        ),
                      if (showHeader)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: HomeHeaderBar(
                            height: headerHeight,
                            topInset: topInset,
                            horizontalPadding: s(14),
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
                        ),
                      if (showHeader &&
                          isMenuOpen &&
                          switchableProfiles.isNotEmpty)
                        Positioned(
                          left: s(28),
                          top: headerHeight - s(6),
                          child: HomeProfileMenu(
                            profiles: switchableProfiles,
                            scale: scale,
                            maxWidth: layoutWidth - s(56),
                            onSelect: (profile) {
                              HapticFeedback.selectionClick();
                              _profileController.switchProfile(
                                profile,
                                activeProfile: widget.activeProfile,
                                onActivateProfile: widget.onActivateProfile,
                                onError: (_) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.readText(
                                          AppKeys.profileUpdateFailed,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: HomeBottomNavigation(
                          height: navHeight,
                          bottomInset: bottomInset,
                          scale: scale,
                          activeIndex: navigation.activeTab,
                          activeRole: widget.activeRole,
                          user: widget.user,
                          onTabSelected: (index) {
                            if (widget.activeRole == ProfileRole.parent &&
                                index != navigation.activeTab &&
                                index == 0) {
                              _playParentHomeEntrance();
                            }
                            homeCubit.selectTab(index);
                          },
                        ),
                      ),
                      // LoadingScreen overlay removed — skeleton in content
                      // area provides loading feedback during profile switch.
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  HomeTabCubit _homeCubitFor(ProfileRole role) {
    return switch (role) {
      ProfileRole.parent => _parentHomeCubit,
      ProfileRole.student => _studentHomeCubit,
      ProfileRole.teacher => _teacherHomeCubit,
    };
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
    final size = MediaQuery.sizeOf(context);
    final scale = math.min(
      math.min(size.width, 430.0) / _designWidth,
      size.height / _designHeight,
    );

    final didSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
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
                scale: scale,
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
