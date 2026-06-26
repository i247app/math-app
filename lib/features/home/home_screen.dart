import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
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
import 'package:numi_flutter/features/home/home_api.dart';
import 'package:numi_flutter/features/home/home_tab_cubit.dart';
import 'package:numi_flutter/features/home/parent/parent_home_cubit.dart';
import 'package:numi_flutter/features/home/student/student_home_cubit.dart';
import 'package:numi_flutter/features/home/teacher/teacher_home_cubit.dart';
import 'package:numi_flutter/features/home/widgets/home_profile_menu.dart';
import 'package:numi_flutter/features/games/presentation/games_tab.dart';
import 'package:numi_flutter/features/profile/grade_api.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/quiz/quiz_api.dart';
import 'package:numi_flutter/features/quiz/presentation/grade_selection_screen.dart';
import 'package:numi_flutter/features/quiz/presentation/quiz_review_screen.dart';
import 'package:numi_flutter/features/homework/presentation/student_homework_attempt_screen.dart';
import 'package:numi_flutter/features/homework/presentation/student_homework_result_screen.dart';
import 'package:numi_flutter/features/classroom/presentation/student_class_detail_screen.dart';
import 'package:numi_flutter/features/classroom/presentation/teacher_classroom_screens.dart';
import 'package:numi_flutter/features/quiz/history_tab.dart';
import 'package:numi_flutter/features/quiz/review_tab.dart';
import 'package:numi_flutter/features/settings/setting_tab.dart';
import 'package:numi_flutter/shared/widgets/common_widgets.dart';
import 'package:numi_flutter/shared/widgets/score_progress_ring.dart';
import 'package:numi_flutter/features/profile/widgets/profile_avatar_image.dart';
import 'package:numi_flutter/features/classroom/widgets/student_class_search_content.dart';

part 'parent/assessment/helpers/parent_assessment_helpers.dart';
part 'parent/assessment/models/parent_assessment_entry.dart';
part 'parent/assessment/parent_assessment_tab.dart';
part 'parent/assessment/widgets/parent_assessment_chart_painter.dart';
part 'parent/assessment/widgets/parent_assessment_header.dart';
part 'parent/assessment/widgets/parent_assessment_list_skeleton.dart';
part 'parent/assessment/widgets/parent_assessment_meta_item.dart';
part 'parent/assessment/widgets/parent_assessment_progress_chart.dart';
part 'parent/assessment/widgets/parent_assessment_score_badge.dart';
part 'parent/assessment/widgets/parent_assessment_search_field.dart';
part 'parent/assessment/widgets/parent_assessment_skeleton_pulse.dart';
part 'parent/assessment/widgets/parent_assessment_state_card.dart';
part 'parent/assessment/widgets/parent_assessment_tab_card.dart';
part 'parent/assessment/widgets/parent_review_tab_banner.dart';
part 'parent/home/helpers/parent_child_dashboard_helpers.dart';
part 'parent/home/models/parent_child_summary.dart';
part 'parent/home/models/parent_home_entrance_builder.dart';
part 'parent/home/parent_home_child_dashboard.dart';
part 'parent/home/parent_home_completed_assessment.dart';
part 'parent/home/parent_home_first_assessment.dart';
part 'parent/home/parent_home_tab.dart';
part 'parent/home/widgets/parent_assessment_result_card.dart';
part 'parent/home/widgets/parent_dashed_circle_painter.dart';
part 'parent/home/widgets/parent_guide_item.dart';
part 'parent/home/widgets/parent_home_error_card.dart';
part 'parent/home/widgets/parent_home_loading_card.dart';
part 'parent/home/widgets/parent_home_refresh_label.dart';
part 'parent/home/widgets/parent_learning_streak_card.dart';
part 'parent/home/widgets/parent_mode_three_class_card.dart';
part 'parent/home/widgets/parent_mode_three_content.dart';
part 'parent/home/widgets/parent_mode_three_game_suggestions.dart';
part 'parent/home/widgets/parent_mode_three_message_item.dart';
part 'parent/home/widgets/parent_mode_three_messages.dart';
part 'parent/home/widgets/parent_mode_one_assessment_banner.dart';
part 'parent/home/widgets/parent_mode_three_section.dart';
part 'parent/home/widgets/parent_profile_dialog_action.dart';
part 'parent/home/widgets/parent_select_student_dialog.dart';
part 'parent/home/widgets/parent_start_guide_card.dart';
part 'parent/home/widgets/parent_streak_day_state.dart';
part 'parent/home/widgets/parent_streak_day.dart';
part 'parent/parent_dashboard.dart';
part 'parent/room/helpers/parent_room_helpers.dart';
part 'parent/room/models/parent_room_entry.dart';
part 'parent/room/parent_room_tab.dart';
part 'parent/room/widgets/parent_room_class_card.dart';
part 'parent/room/widgets/parent_room_class_grid.dart';
part 'parent/room/widgets/parent_room_completion_card.dart';
part 'parent/room/widgets/parent_room_detail_hero.dart';
part 'parent/room/widgets/parent_room_detail_meta.dart';
part 'parent/room/widgets/parent_room_detail_screen.dart';
part 'parent/room/widgets/parent_room_detail_shortcuts.dart';
part 'parent/room/widgets/parent_room_detail_top_bar.dart';
part 'parent/room/widgets/parent_room_empty_box.dart';
part 'parent/room/widgets/parent_room_header.dart';
part 'parent/room/widgets/parent_room_list_section.dart';
part 'parent/room/widgets/parent_room_loading_content.dart';
part 'parent/room/widgets/parent_room_loading.dart';
part 'parent/room/widgets/parent_room_pending_card.dart';
part 'parent/room/widgets/parent_room_section_title.dart';
part 'parent/room/widgets/parent_room_shortcut_tile.dart';
part 'parent/room/widgets/parent_room_skeleton_block.dart';
part 'parent/room/widgets/parent_room_skeleton_line.dart';
part 'parent/room/widgets/parent_room_state_card.dart';
part 'parent/room/widgets/parent_room_status_icon.dart';
part 'parent/room/widgets/parent_room_task_header.dart';
part 'parent/room/widgets/parent_room_task_shell.dart';
part 'parent/shared/parent_home_helpers.dart';
part 'parent/shared/widgets/parent_child_dashboard_loading.dart';
part 'parent/shared/widgets/parent_home_entrance.dart';
part 'parent/shared/widgets/parent_image_action.dart';
part 'parent/shared/widgets/parent_room_badge_row.dart';
part 'parent/shared/widgets/parent_room_chip.dart';
part 'parent/shared/widgets/parent_room_completion_list_item.dart';
part 'parent/shared/widgets/parent_room_empty_line.dart';
part 'parent/shared/widgets/parent_room_list_date_label.dart';
part 'parent/shared/widgets/parent_room_list_icon_box.dart';
part 'parent/shared/widgets/parent_room_list_title.dart';
part 'parent/shared/widgets/parent_room_pending_list_item.dart';
part 'parent/shared/widgets/parent_room_score_icon.dart';
part 'parent/shared/widgets/parent_shimmer_transform.dart';
part 'parent/shared/widgets/parent_skeleton_block.dart';
part 'parent/shared/widgets/parent_skeleton_line.dart';
part 'parent/shared/widgets/parent_skeleton_shimmer.dart';
part 'student/student_dashboard.dart';
part 'student/student_home_mode_one.dart';
part 'student/student_home_mode_two.dart';
part 'student/student_home_mode_three.dart';
part 'teacher/teacher_dashboard.dart';
part 'widgets/home_dashboard_args.dart';
part 'widgets/home_role_dashboard.dart';
part 'widgets/home_background.dart';
part 'widgets/home_header_bar.dart';
part 'widgets/home_bottom_navigation.dart';

const _teal = Color(0xFF006762);
const _muted = Color(0xFF515F54);
const _deepInk = Color(0xFF253228);
const _mintBackground = Color(0xFFEEF9FB);
const _studentHomeBell = 'assets/images/student_home_bell.svg';
const _studentHomeInvite = 'assets/images/student_home_invite.svg';
const _parentHomeAfterReviewBanner =
    'assets/images/parent_banner_after_review.jpg';
const _parentHomeModeOneAssessmentBanner =
    'assets/images/parent_home_mode1_assessment_banner.jpg';
const _parentHomeClassroom = 'assets/images/join_classroom.jpg';
const _parentHomeRace = 'assets/images/parent_home_race.png';
const _parentHomeShop = 'assets/images/parent_home_shop.png';
const _studentParentHomeClassThumb =
    'assets/images/student_parent_home_class_thumb.png';
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
const _homeFadeInDuration = Duration(milliseconds: 900);

enum _HomeTabDestination {
  home,
  classroom,
  room,
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
      duration: _homeFadeInDuration,
    );
    if (widget.activeRole == ProfileRole.parent) {
      _parentHomeEntranceController.forward();
    }
    _prefetchGrades();
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
    if (oldProfileId != profileId) {
      _isProfileMenuOpen = false;
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
          3 => _HomeTabDestination.review,
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
          _HomeTabDestination.room || _HomeTabDestination.classroom => 2,
          _HomeTabDestination.review => 3,
          _HomeTabDestination.settings => 4,
          _ => 0,
        },
      ProfileRole.student => switch (destination) {
          _HomeTabDestination.classroom || _HomeTabDestination.room => 1,
          _HomeTabDestination.review => 2,
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
                  const Positioned.fill(child: HomeBackground()),
                  Positioned.fill(
                    child: HomeRoleDashboard(
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
                        homeCubit.selectTab(3);
                      },
                      openAddProfileRequestId: _openAddProfileRequestId,
                      onCompleteTeacherProfile: _openTeacherProfileForm,
                      onOpenClassroomTab: () => homeCubit.selectTab(
                        widget.activeRole == ProfileRole.parent ? 2 : 1,
                      ),
                      onOpenReviewTab: () {
                        HapticFeedback.lightImpact();
                        homeCubit.selectTab(
                          widget.activeRole == ProfileRole.parent ? 3 : 2,
                        );
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
                      child: HomeHeaderBar(
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
                    child: HomeBottomNavigation(
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
