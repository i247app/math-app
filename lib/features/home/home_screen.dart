import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_models.dart';
import 'package:numi_flutter/core/network/grade_models.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/core/network/quiz_models.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/profile/active_profile_session.dart';
import 'package:numi_flutter/features/classroom/classroom_api.dart';
import 'package:numi_flutter/features/classroom/presentation/bloc/classroom_cubit.dart';
import 'package:numi_flutter/features/classroom/presentation/bloc/classroom_state.dart';
import 'package:numi_flutter/features/homework/homework_api.dart';
import 'package:numi_flutter/features/home/home_tab_cubit.dart';
import 'package:numi_flutter/features/home/parent/parent_home_cubit.dart';
import 'package:numi_flutter/features/home/student/student_home_cubit.dart';
import 'package:numi_flutter/features/home/teacher/teacher_home_cubit.dart';
import 'package:numi_flutter/features/home/widgets/home_profile_menu.dart';
import 'package:numi_flutter/features/profile/grade_api.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/quiz/quiz_api.dart';
import 'package:numi_flutter/features/quiz/presentation/grade_selection_screen.dart';
import 'package:numi_flutter/features/quiz/presentation/quiz_review_screen.dart';
import 'package:numi_flutter/features/classroom/presentation/student_class_detail_screen.dart';
import 'package:numi_flutter/features/classroom/presentation/teacher_classroom_screens.dart';
import 'package:numi_flutter/features/quiz/history_tab.dart';
import 'package:numi_flutter/features/quiz/review_tab.dart';
import 'package:numi_flutter/features/settings/setting_tab.dart';
import 'package:numi_flutter/shared/widgets/common_widgets.dart';
import 'package:numi_flutter/features/profile/widgets/profile_avatar_image.dart';
import 'package:numi_flutter/features/classroom/widgets/student_class_search_content.dart';

part 'parent/parent_dashboard.dart';
part 'parent/parent_assessment_tab.dart';
part 'student/student_dashboard.dart';
part 'teacher/teacher_dashboard.dart';

const _teal = Color(0xFF006762);
const _muted = Color(0xFF515F54);
const _deepInk = Color(0xFF253228);
const _mintBackground = Color(0xFFEEF9FB);
const _studentHomeBell = 'assets/images/student_home_bell.svg';
const _studentHomeInvite = 'assets/images/student_home_invite.svg';
const _studentParentHomeHeroBg =
    'assets/images/student_parent_home_hero_bg.png';
const _studentParentHomeHeroArt =
    'assets/images/student_parent_home_hero_art.png';
const _parentHomeWelcomeMap = 'assets/images/map_welcome_new.png';
const _parentHomeAfterReviewBanner =
    'assets/images/parent_banner_after_review.jpg';
const _parentHomeClassroom = 'assets/images/join_classroom.jpg';
const _parentHomeRace = 'assets/images/parent_home_race.png';
const _parentHomeShop = 'assets/images/parent_home_shop.png';
const _studentParentHomeClassThumb =
    'assets/images/student_parent_home_class_thumb.png';
const _studentParentHomeAssessmentIcon =
    'assets/images/student_parent_home_assessment_icon.svg';
const _studentParentHomeAcceptIcon =
    'assets/images/student_parent_home_accept.png';
const _studentParentHomeRejectIcon =
    'assets/images/student_parent_home_reject.png';
const _studentParentHomeJoinIcon =
    'assets/images/student_parent_home_join_icon.svg';
const _studentHomeNavHome = 'assets/images/student_home_nav_home.svg';
const _studentHomeNavClass = 'assets/images/student_home_nav_class.svg';
const _studentHomeNavReport = 'assets/images/student_home_nav_report.svg';
const _studentHomeNavMessage = 'assets/images/student_home_nav_message.svg';
const _studentHomeNavSettings = 'assets/images/student_home_nav_settings.svg';
const _parentNoStudentMascot = 'assets/images/parent_no_student_mascot.png';
const _homeTeacherAvatarOne = 'assets/images/student_home_avatar.png';
const _homeTeacherAvatarTwo = 'assets/images/student_class_teacher.png';
const _homeProfileSwitchMinimumDuration = Duration(milliseconds: 1500);
const _homeFadeInDuration = Duration(milliseconds: 1000);

enum _HomeTabDestination {
  home,
  classroom,
  assessment,
  review,
  history,
  study,
  members,
  settings,
}

String _homeRoleLabel(BuildContext context, ProfileRole role) {
  return switch (role) {
    ProfileRole.parent => context.getText(AppKeys.roleParent).toUpperCase(),
    ProfileRole.teacher => context.getText(AppKeys.roleTeacher).toUpperCase(),
    ProfileRole.student => context.getText(AppKeys.roleStudent).toUpperCase(),
  };
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
  })  : _gradeService = gradeService,
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
  late final GradeService _gradeService = widget._gradeService ?? GradeApi();
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();
  late final ClassroomExerciseService _assignmentService =
      widget._assignmentService ?? ClassroomExerciseApi();
  late final QuizService _quizService = widget._quizService ?? QuizApi();
  final ParentHomeCubit _parentHomeCubit = ParentHomeCubit();
  final StudentHomeCubit _studentHomeCubit = StudentHomeCubit();
  final TeacherHomeCubit _teacherHomeCubit = TeacherHomeCubit();
  late final AnimationController _parentHomeEntranceController;
  int _openAddProfileRequestId = 0;
  bool _returnToReviewAfterProfileSave = false;
  int? _prefetchedGradeUserId;
  bool _isPrefetchingGrades = false;
  bool _isProfileMenuOpen = false;
  bool _isSwitchingProfile = false;
  int _parentStreakCount = 1;
  List<GradeModel> _prefetchedGrades = const <GradeModel>[];

  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

  @override
  void initState() {
    super.initState();
    _parentHomeEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.activeRole == ProfileRole.parent) {
      _parentHomeEntranceController.forward();
    }
    _prefetchGrades();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.id != widget.user?.id) {
      _prefetchedGrades = const <GradeModel>[];
      _prefetchedGradeUserId = null;
      _prefetchGrades();
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
    if (oldWidget.activeProfile != widget.activeProfile) {
      _isProfileMenuOpen = false;
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
          2 => _HomeTabDestination.review,
          3 => _HomeTabDestination.history,
          4 => _HomeTabDestination.settings,
          _ => _HomeTabDestination.home,
        },
      ProfileRole.student => switch (currentIndex) {
          1 => _HomeTabDestination.classroom,
          2 => _HomeTabDestination.review,
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
          _HomeTabDestination.review => 2,
          _HomeTabDestination.history => 3,
          _HomeTabDestination.settings => 4,
          _ => 0,
        },
      ProfileRole.student => switch (destination) {
          _HomeTabDestination.classroom => 1,
          _HomeTabDestination.review => 2,
          _HomeTabDestination.history => 3,
          _HomeTabDestination.settings => 4,
          _ => 0,
        },
      ProfileRole.teacher => switch (destination) {
          _HomeTabDestination.classroom => 1,
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
    _parentHomeCubit.close();
    _studentHomeCubit.close();
    _teacherHomeCubit.close();
    super.dispose();
  }

  Future<void> _prefetchGrades() async {
    final userId = widget.user?.id;
    if (userId == null ||
        userId <= 0 ||
        _isPrefetchingGrades ||
        (_prefetchedGradeUserId == userId && _prefetchedGrades.isNotEmpty)) {
      return;
    }

    _isPrefetchingGrades = true;
    _prefetchedGradeUserId = userId;

    try {
      final grades = await _gradeService.listGrades(userId: userId);
      if (!mounted || widget.user?.id != userId) {
        return;
      }

      setState(() => _prefetchedGrades = grades);
    } catch (_) {
      if (!mounted || widget.user?.id != userId) {
        return;
      }

      setState(() => _prefetchedGrades = const <GradeModel>[]);
    } finally {
      _isPrefetchingGrades = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeCubit = _homeCubitFor(widget.activeRole);
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
              layoutWidth / _designWidth, viewportHeight / _designHeight);
          final studentName = compactHomeProfileName(
            _displayProfileName(
              context,
              widget.activeProfile,
              widget.activeRole,
            ),
          );

          double s(double value) => value * scale;
          final navHeight = s(88) + bottomInset;
          final headerHeight = s(
                widget.activeRole == ProfileRole.parent ? 64 : 98,
              ) +
              topInset;
          final showHeader = widget.activeRole != ProfileRole.teacher &&
              navigation.activeTab == 0;
          final switchableProfiles = widget.profiles
              .where(
                (profile) =>
                    ActiveProfileSession.profileStableId(profile) !=
                    ActiveProfileSession.profileStableId(widget.activeProfile),
              )
              .toList(growable: false);
          return Center(
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned.fill(child: _HomeBackground()),
                  Positioned.fill(
                    child: _RoleDashboard(
                      key: ValueKey(
                        '${widget.activeRole}-${ActiveProfileSession.profileStableId(widget.activeProfile)}',
                      ),
                      activeTab: navigation.activeTab,
                      user: widget.user,
                      profiles: widget.profiles,
                      activeProfile: widget.activeProfile,
                      activeRole: widget.activeRole,
                      profileLoadError: widget.profileLoadError,
                      onRefreshProfiles: widget.onRefreshProfiles,
                      onActivateProfile: widget.onActivateProfile,
                      initialGrades: _prefetchedGrades,
                      gradeService: _gradeService,
                      classroomService: _classroomService,
                      assignmentService: _assignmentService,
                      quizService: _quizService,
                      onLogout: widget.onLogout,
                      onAddProfileFromReview: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _returnToReviewAfterProfileSave = true;
                          _openAddProfileRequestId++;
                        });
                        homeCubit.selectTab(
                          4,
                        );
                      },
                      onProfileSaved: () {
                        if (!_returnToReviewAfterProfileSave) {
                          return;
                        }

                        setState(() {
                          _returnToReviewAfterProfileSave = false;
                        });
                        homeCubit.selectTab(
                          2,
                        );
                      },
                      openAddProfileRequestId: _openAddProfileRequestId,
                      onCompleteTeacherProfile: _openTeacherProfileForm,
                      onOpenClassroomTab: () => homeCubit.selectTab(1),
                      onOpenReviewTab: () {
                        HapticFeedback.lightImpact();
                        homeCubit.selectTab(2);
                      },
                      onOpenProfileMenu: () {
                        if (switchableProfiles.isEmpty || _isProfileMenuOpen) {
                          return;
                        }
                        HapticFeedback.selectionClick();
                        setState(() => _isProfileMenuOpen = true);
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
                  if (_isProfileMenuOpen)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => setState(() => _isProfileMenuOpen = false),
                      ),
                    ),
                  if (showHeader)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: _HeaderBar(
                        height: headerHeight,
                        topInset: topInset,
                        horizontalPadding: s(24),
                        name: studentName,
                        profile: widget.activeProfile,
                        role: widget.activeRole,
                        canSwitchProfile: switchableProfiles.isNotEmpty,
                        isProfileMenuOpen: _isProfileMenuOpen,
                        parentStreakCount: _parentStreakCount,
                        onProfileTap: switchableProfiles.isEmpty
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                setState(
                                  () =>
                                      _isProfileMenuOpen = !_isProfileMenuOpen,
                                );
                              },
                      ),
                    ),
                  if (showHeader &&
                      _isProfileMenuOpen &&
                      switchableProfiles.isNotEmpty)
                    Positioned(
                      left: s(28),
                      top: widget.activeRole == ProfileRole.parent
                          ? headerHeight - s(6)
                          : headerHeight - s(22),
                      child: HomeProfileMenu(
                        profiles: switchableProfiles,
                        scale: scale,
                        maxWidth: layoutWidth - s(56),
                        onSelect: _switchProfile,
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _BottomNavigation(
                      height: navHeight,
                      bottomInset: bottomInset,
                      scale: scale,
                      activeIndex: navigation.activeTab,
                      activeRole: widget.activeRole,
                      user: widget.user,
                      onTabSelected: (index) {
                        if (index == navigation.activeTab) {
                          return;
                        }

                        if (widget.activeRole == ProfileRole.parent &&
                            index == 0) {
                          _playParentHomeEntrance();
                        }
                        homeCubit.selectTab(index);
                      },
                    ),
                  ),
                  if (_isSwitchingProfile)
                    Positioned.fill(
                      child: LoadingScreen(
                        message: context.getText(AppKeys.switchingProfile),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
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

  Future<void> _switchProfile(StudentProfile profile) async {
    if (_isSwitchingProfile ||
        ActiveProfileSession.profileStableId(profile) ==
            ActiveProfileSession.profileStableId(widget.activeProfile)) {
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _isProfileMenuOpen = false;
      _isSwitchingProfile = true;
    });

    try {
      await Future.wait<void>([
        widget.onActivateProfile(profile),
        Future<void>.delayed(_homeProfileSwitchMinimumDuration),
      ]);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.readText(AppKeys.profileUpdateFailed))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSwitchingProfile = false);
      }
    }
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
    return switch (role) {
      ProfileRole.parent => context.getText(AppKeys.roleParent),
      ProfileRole.teacher => context.getText(AppKeys.roleTeacher),
      ProfileRole.student => context.getText(AppKeys.roleStudent),
    };
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
          color: Colors.white,
          child: SafeArea(
            child: SettingTab.page(
              user: widget.user,
              profiles: widget.profiles,
              activeProfile: widget.activeProfile,
              profileLoadError: widget.profileLoadError,
              onLogout: widget.onLogout,
              onActivateProfile: widget.onActivateProfile,
              onRefreshProfiles: widget.onRefreshProfiles,
              onProfileSaved: () => Navigator.of(routeContext).pop(true),
              bottomPadding: 0,
              scale: scale,
              initialView: SettingPageView.addProfile,
              initialEditingProfile: profile,
              isPushedPage: true,
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

class HomeDashboardArgs {
  const HomeDashboardArgs({
    required this.activeTab,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.profileLoadError,
    required this.onRefreshProfiles,
    required this.onActivateProfile,
    required this.initialGrades,
    required this.gradeService,
    required this.classroomService,
    required this.assignmentService,
    required this.quizService,
    required this.onLogout,
    required this.onAddProfileFromReview,
    required this.onProfileSaved,
    required this.openAddProfileRequestId,
    required this.onCompleteTeacherProfile,
    required this.onOpenClassroomTab,
    required this.onOpenReviewTab,
    required this.onOpenProfileMenu,
    required this.onParentAssessmentStateChanged,
    required this.parentHomeEntrance,
    required this.activeRefreshTick,
    required this.bottomPadding,
    required this.headerHeight,
    required this.scale,
  });

  final int activeTab;
  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final String? profileLoadError;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final ClassroomService classroomService;
  final ClassroomExerciseService assignmentService;
  final QuizService quizService;
  final VoidCallback onLogout;
  final VoidCallback onAddProfileFromReview;
  final VoidCallback onProfileSaved;
  final int openAddProfileRequestId;
  final Future<void> Function() onCompleteTeacherProfile;
  final VoidCallback onOpenClassroomTab;
  final VoidCallback onOpenReviewTab;
  final VoidCallback onOpenProfileMenu;
  final ValueChanged<bool> onParentAssessmentStateChanged;
  final Animation<double> parentHomeEntrance;
  final int activeRefreshTick;
  final double bottomPadding;
  final double headerHeight;
  final double scale;

  EdgeInsets get contentPadding => EdgeInsets.only(
        left: 24 * scale,
        right: 24 * scale,
        top: headerHeight + (activeTab == 0 ? 0 : 24 * scale),
        bottom: bottomPadding,
      );
}

class _RoleDashboard extends StatefulWidget {
  const _RoleDashboard({
    super.key,
    required this.activeTab,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.activeRole,
    required this.profileLoadError,
    required this.onRefreshProfiles,
    required this.onActivateProfile,
    required this.initialGrades,
    required this.gradeService,
    required this.classroomService,
    required this.assignmentService,
    required this.quizService,
    required this.onLogout,
    required this.onAddProfileFromReview,
    required this.onProfileSaved,
    required this.openAddProfileRequestId,
    required this.onCompleteTeacherProfile,
    required this.onOpenClassroomTab,
    required this.onOpenReviewTab,
    required this.onOpenProfileMenu,
    required this.onParentAssessmentStateChanged,
    required this.parentHomeEntrance,
    required this.bottomPadding,
    required this.headerHeight,
    required this.scale,
  });

  final int activeTab;
  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final ProfileRole activeRole;
  final String? profileLoadError;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final ClassroomService classroomService;
  final ClassroomExerciseService assignmentService;
  final QuizService quizService;
  final VoidCallback onLogout;
  final VoidCallback onAddProfileFromReview;
  final VoidCallback onProfileSaved;
  final int openAddProfileRequestId;
  final Future<void> Function() onCompleteTeacherProfile;
  final VoidCallback onOpenClassroomTab;
  final VoidCallback onOpenReviewTab;
  final VoidCallback onOpenProfileMenu;
  final ValueChanged<bool> onParentAssessmentStateChanged;
  final Animation<double> parentHomeEntrance;
  final double bottomPadding;
  final double headerHeight;
  final double scale;

  @override
  State<_RoleDashboard> createState() => _RoleDashboardState();
}

class _RoleDashboardState extends State<_RoleDashboard> {
  late final Set<int> _visitedTabs = <int>{widget.activeTab};
  late final Set<int> _activatedTabs = <int>{widget.activeTab};
  final Map<int, int> _activationTicks = <int, int>{};

  @override
  void initState() {
    super.initState();
    _activationTicks[widget.activeTab] = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) => _prewarmTabs());
  }

  Future<void> _prewarmTabs() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    const tabOrder = <int>[1, 2, 3, 4, 0];
    for (final tab in tabOrder) {
      if (!mounted) {
        return;
      }
      if (tab == widget.activeTab || _visitedTabs.contains(tab)) {
        continue;
      }

      setState(() {
        _visitedTabs.add(tab);
        _activationTicks[tab] = 1;
      });
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  void didUpdateWidget(covariant _RoleDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeTab != widget.activeTab) {
      _visitedTabs.add(widget.activeTab);
      final isFirstActivation = _activatedTabs.add(widget.activeTab);
      if (isFirstActivation) {
        _activationTicks[widget.activeTab] ??= 1;
      } else {
        _activationTicks[widget.activeTab] =
            (_activationTicks[widget.activeTab] ?? 0) + 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxTabIndex = 4;
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var tab = 0; tab <= maxTabIndex; tab++)
          if (_visitedTabs.contains(tab))
            Offstage(
              key: ValueKey('home-tab-$tab'),
              offstage: tab != widget.activeTab,
              child: TickerMode(
                enabled: tab == widget.activeTab,
                child: _buildTab(context, tab),
              ),
            ),
      ],
    );
  }

  Widget _buildTab(BuildContext context, int tab) {
    final args = HomeDashboardArgs(
      activeTab: tab,
      user: widget.user,
      profiles: widget.profiles,
      activeProfile: widget.activeProfile,
      profileLoadError: widget.profileLoadError,
      onRefreshProfiles: widget.onRefreshProfiles,
      onActivateProfile: widget.onActivateProfile,
      initialGrades: widget.initialGrades,
      gradeService: widget.gradeService,
      classroomService: widget.classroomService,
      assignmentService: widget.assignmentService,
      quizService: widget.quizService,
      onLogout: widget.onLogout,
      onAddProfileFromReview: widget.onAddProfileFromReview,
      onProfileSaved: widget.onProfileSaved,
      openAddProfileRequestId: widget.openAddProfileRequestId,
      onCompleteTeacherProfile: widget.onCompleteTeacherProfile,
      onOpenClassroomTab: widget.onOpenClassroomTab,
      onOpenReviewTab: widget.onOpenReviewTab,
      onOpenProfileMenu: widget.onOpenProfileMenu,
      onParentAssessmentStateChanged: widget.onParentAssessmentStateChanged,
      parentHomeEntrance: widget.parentHomeEntrance,
      activeRefreshTick: _activationTicks[tab] ?? 0,
      bottomPadding: widget.bottomPadding,
      headerHeight: tab == 0 ? widget.headerHeight : 0,
      scale: widget.scale,
    );

    return switch (widget.activeRole) {
      ProfileRole.parent => ParentDashboard(args: args),
      ProfileRole.student => StudentDashboard(args: args),
      ProfileRole.teacher => TeacherDashboard(args: args),
    };
  }
}

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x3300504B),
            blurRadius: 44,
            offset: Offset(0, 28),
          ),
        ],
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.height,
    required this.topInset,
    required this.horizontalPadding,
    required this.name,
    required this.profile,
    required this.role,
    required this.canSwitchProfile,
    required this.isProfileMenuOpen,
    required this.parentStreakCount,
    required this.onProfileTap,
  });

  final double height;
  final double topInset;
  final double horizontalPadding;
  final String name;
  final StudentProfile? profile;
  final ProfileRole role;
  final bool canSwitchProfile;
  final bool isProfileMenuOpen;
  final int parentStreakCount;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final contentHeight = height - topInset;
    final typographyScale =
        contentHeight / (role == ProfileRole.parent ? 64 : 98);
    if (role == ProfileRole.parent) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: height,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding * 0.82,
              topInset + contentHeight * 0.10,
              horizontalPadding * 0.72,
              contentHeight * 0.10,
            ),
            color: Colors.white.withValues(alpha: 0.96),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: canSwitchProfile,
                    child: InkWell(
                      onTap: onProfileTap,
                      borderRadius: BorderRadius.circular(16),
                      child: Row(
                        children: [
                          ProfileAvatarImage(
                            size: contentHeight * 0.74,
                            avatarKey: profile?.avatarKey,
                            avatarUrl: profile?.avatarUrl,
                            borderColor:
                                const Color(0xFFE7DAC8).withValues(alpha: 0.9),
                            borderWidth: 1.5,
                          ),
                          SizedBox(width: contentHeight * 0.16),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _homeRoleLabel(context, role),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: const Color(0xFF6782AA),
                                    fontSize:
                                        FontSize.avatarMini * typographyScale,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    height: 1,
                                  ),
                                ),
                                SizedBox(height: contentHeight * 0.06),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: const Color(0xFF002B6A),
                                          fontSize: FontSize.avatarName *
                                              typographyScale,
                                          fontWeight: FontWeight.w900,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                    if (canSwitchProfile) ...[
                                      SizedBox(width: contentHeight * 0.04),
                                      AnimatedRotation(
                                        turns: isProfileMenuOpen ? 0.5 : 0,
                                        duration:
                                            const Duration(milliseconds: 180),
                                        child: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: contentHeight * 0.26,
                                          color: const Color(0xFF8294B0),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _ParentFireBadge(
                  count: parentStreakCount,
                  height: contentHeight * 0.48,
                ),
                SizedBox(width: contentHeight * 0.12),
                _NotificationButton(size: contentHeight * 0.58),
              ],
            ),
          ),
        ),
      );
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: height,
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topInset + contentHeight * 0.20,
            horizontalPadding,
            contentHeight * 0.21,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
          ),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  button: canSwitchProfile,
                  child: InkWell(
                    onTap: onProfileTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StudentAvatar(
                          size: contentHeight * 0.45,
                          avatarKey: profile?.avatarKey,
                          avatarUrl: profile?.avatarUrl,
                        ),
                        SizedBox(width: contentHeight * 0.14),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _homeRoleLabel(context, role),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _muted.withValues(alpha: 0.6),
                                  fontSize:
                                      FontSize.avatarMini * typographyScale,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.8,
                                  height: 1,
                                ),
                              ),
                              SizedBox(height: contentHeight * 0.06),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '$name👋',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(0xFF002B6A),
                                        fontSize: FontSize.avatarName *
                                            typographyScale,
                                        fontWeight: FontWeight.w900,
                                        height: 1,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                  if (canSwitchProfile) ...[
                                    SizedBox(width: contentHeight * 0.06),
                                    AnimatedRotation(
                                      turns: isProfileMenuOpen ? 0.5 : 0,
                                      duration:
                                          const Duration(milliseconds: 180),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: contentHeight * 0.18,
                                        color: const Color(0xFF8294B0),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _NotificationButton(size: contentHeight * 0.45),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParentFireBadge extends StatelessWidget {
  const _ParentFireBadge({
    required this.count,
    required this.height,
  });

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      constraints: BoxConstraints(minWidth: height * 1.5),
      padding: EdgeInsets.symmetric(horizontal: height * 0.30),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EC),
        borderRadius: BorderRadius.circular(height),
        border: Border.all(color: const Color(0xFFFFCBAF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: const Color(0xFFFF650B),
            size: height * 0.66,
          ),
          Text(
            '$count',
            style: TextStyle(
              color: const Color(0xFFFF650B),
              fontSize: FontSize.caption * (height / 30),
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({required this.size, this.avatarKey, this.avatarUrl});

  final double size;
  final String? avatarKey;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _teal.withValues(alpha: 0.05),
                spreadRadius: size * 0.08,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.11),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ProfileAvatarImage(
            size: size,
            avatarKey: avatarKey,
            avatarUrl: avatarUrl,
          ),
        ),
        Positioned(
          right: -size * 0.05,
          bottom: -size * 0.05,
          child: Container(
            width: size * 0.32,
            height: size * 0.32,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              shape: BoxShape.circle,
              border: Border.all(color: _mintBackground, width: size * 0.05),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      elevation: 2,
      borderRadius: BorderRadius.circular(size * 0.36),
      child: InkWell(
        onTap: HapticFeedback.selectionClick,
        borderRadius: BorderRadius.circular(size * 0.36),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SvgPicture.asset(
              _studentHomeBell,
              width: size * 0.40,
              height: size * 0.50,
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.height,
    required this.bottomInset,
    required this.scale,
    required this.activeIndex,
    required this.activeRole,
    required this.user,
    required this.onTabSelected,
  });

  final double height;
  final double bottomInset;
  final double scale;
  final int activeIndex;
  final ProfileRole activeRole;
  final LoginUser? user;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final items = switch (activeRole) {
      ProfileRole.teacher => [
          _NavItemData(
            Icons.home_filled,
            context.getText(AppKeys.navHome),
            null,
          ),
          _NavItemData(
            Icons.bar_chart_rounded,
            context.getText(AppKeys.navClassroom),
            null,
          ),
          _NavItemData(
            Icons.menu_book_rounded,
            context.getText(AppKeys.navStudy),
            null,
          ),
          _NavItemData(
            Icons.chat_bubble_outline_rounded,
            context.getText(AppKeys.navMembers),
            null,
          ),
          _NavItemData(null, context.getText(AppKeys.navSettings), user),
        ],
      ProfileRole.student => [
          _NavItemData(
            null,
            context.getText(AppKeys.navHome),
            null,
            assetPath: _studentHomeNavHome,
          ),
          _NavItemData(
            null,
            context.getText(AppKeys.navClassroom),
            null,
            assetPath: _studentHomeNavClass,
          ),
          _NavItemData(
            null,
            context.getText(AppKeys.navReview),
            null,
            assetPath: _studentHomeNavReport,
          ),
          _NavItemData(
            null,
            context.getText(AppKeys.navHistory),
            null,
            assetPath: _studentHomeNavMessage,
          ),
          _NavItemData(
            null,
            context.getText(AppKeys.navSettings),
            null,
            assetPath: _studentHomeNavSettings,
          ),
        ],
      ProfileRole.parent => [
          _NavItemData(
            Icons.home_filled,
            context.getText(AppKeys.navHome),
            null,
          ),
          _NavItemData(
            Icons.assignment_turned_in_outlined,
            context.getText(AppKeys.navAssessment),
            null,
          ),
          _NavItemData(
            Icons.explore_outlined,
            context.getText(AppKeys.navProgram),
            null,
          ),
          _NavItemData(
            Icons.history,
            context.getText(AppKeys.navHistory),
            null,
          ),
          _NavItemData(null, context.getText(AppKeys.navSettings), user),
        ],
    };

    final radius = BorderRadius.vertical(
      top: Radius.circular(48 * scale),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30 * scale,
            offset: Offset(0, -8 * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: height,
            padding: EdgeInsets.fromLTRB(
              20 * scale,
              12 * scale,
              20 * scale,
              bottomInset + 12 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: radius,
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                return Expanded(
                  child: _AnimatedNavItem(
                    data: items[index],
                    active: activeIndex == index,
                    teacherStyle: activeRole == ProfileRole.teacher,
                    scale: scale,
                    onTap: () => onTabSelected(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavItem extends StatelessWidget {
  const _AnimatedNavItem({
    required this.data,
    required this.active,
    required this.teacherStyle,
    required this.scale,
    required this.onTap,
  });

  final _NavItemData data;
  final bool active;
  final bool teacherStyle;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF38898B);
    final inactiveColor = const Color(0xFF515F54).withValues(alpha: 0.68);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(end: active ? 1 : 0),
      builder: (context, value, child) {
        final color = Color.lerp(inactiveColor, Colors.white, value)!;
        return AnimatedScale(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          scale: active ? 1 : 0.98,
          child: Semantics(
            selected: active,
            button: true,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(48 * scale),
                child: Container(
                  height: 60 * scale,
                  margin: EdgeInsets.symmetric(horizontal: 2 * scale),
                  padding: EdgeInsets.symmetric(
                    horizontal: 4 * scale,
                    vertical: 9 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: active ? activeColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(48 * scale),
                    boxShadow: active && !teacherStyle
                        ? [
                            BoxShadow(
                              color: _teal.withValues(alpha: 0.20),
                              blurRadius: 15 * scale,
                              offset: Offset(0, 10 * scale),
                            ),
                            BoxShadow(
                              color: _teal.withValues(alpha: 0.20),
                              blurRadius: 6 * scale,
                              offset: Offset(0, 4 * scale),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox.square(
                        dimension: 22 * scale,
                        child: Center(
                          child: data.user != null
                              ? _UserAvatarWidget(
                                  user: data.user!,
                                  size: 20 * scale,
                                  color: color,
                                )
                              : data.assetPath != null
                                  ? SvgPicture.asset(
                                      data.assetPath!,
                                      width: 20 * scale,
                                      height: 20 * scale,
                                      colorFilter: ColorFilter.mode(
                                        color,
                                        BlendMode.srcIn,
                                      ),
                                    )
                                  : Icon(
                                      data.icon,
                                      color: color,
                                      size: 20 * scale,
                                    ),
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            data.label,
                            maxLines: 1,
                            style: TextStyle(
                              color: color,
                              fontSize: FontSize.caption * 0.77 * scale,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UserAvatarWidget extends StatelessWidget {
  const _UserAvatarWidget({
    required this.user,
    required this.size,
    required this.color,
  });

  final LoginUser user;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ProfileAvatarImage(
      size: size,
      avatarUrl: user.avatarUrl,
      foregroundColor: color,
      borderColor: color,
      borderWidth: 1.5,
      iconScale: 0.58,
    );
  }
}

class _NavItemData {
  const _NavItemData(
    this.icon,
    this.label,
    this.user, {
    this.assetPath,
  });

  final IconData? icon;
  final String label;
  final LoginUser? user;
  final String? assetPath;
}
