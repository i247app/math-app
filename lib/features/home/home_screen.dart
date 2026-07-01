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
import 'package:numi_flutter/features/home/cache/home_profile_cache.dart';
import 'package:numi_flutter/features/home/home_api.dart';
import 'package:numi_flutter/features/home/home_profile_controller.dart';
import 'package:numi_flutter/features/home/home_tab_cubit.dart';
import 'package:numi_flutter/features/home/helpers/home_dashboard_helpers.dart';
import 'package:numi_flutter/features/home/parent/cache/parent_home_snapshot.dart';
import 'package:numi_flutter/features/home/parent/parent_home_cubit.dart';
import 'package:numi_flutter/features/home/student/cache/student_home_snapshot.dart';
import 'package:numi_flutter/features/home/student/student_home_cubit.dart';
import 'package:numi_flutter/features/home/teacher/teacher_dashboard.dart';
import 'package:numi_flutter/features/home/teacher/teacher_home_cubit.dart';
import 'package:numi_flutter/features/home/widgets/home_background.dart';
import 'package:numi_flutter/features/home/widgets/home_bottom_navigation.dart';
import 'package:numi_flutter/features/home/widgets/home_dashboard_args.dart';
import 'package:numi_flutter/features/home/widgets/home_game_preview_card.dart';
import 'package:numi_flutter/features/home/widgets/home_header_bar.dart';
import 'package:numi_flutter/features/home/widgets/home_image_action.dart';
import 'package:numi_flutter/features/home/widgets/home_initial_assessment_banner.dart';
import 'package:numi_flutter/features/home/widgets/home_math_squadron_preview_artwork.dart';
import 'package:numi_flutter/features/home/widgets/home_missing_student_dialog.dart';
import 'package:numi_flutter/features/home/widgets/home_profile_menu.dart';
import 'package:numi_flutter/features/home/widgets/home_start_guide_card.dart';
import 'package:numi_flutter/features/home/widgets/home_tab_header.dart';
import 'package:numi_flutter/features/games/presentation/games_tab.dart';
import 'package:numi_flutter/features/profile/grade_api.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/quiz/quiz_api.dart';
import 'package:numi_flutter/features/quiz/presentation/grade_selection_screen.dart';
import 'package:numi_flutter/features/quiz/presentation/quiz_review_screen.dart';
import 'package:numi_flutter/features/homework/presentation/student_homework_attempt_screen.dart';
import 'package:numi_flutter/features/homework/student_homework_open_guard.dart';
import 'package:numi_flutter/features/classroom/presentation/student_class_detail_screen.dart';
import 'package:numi_flutter/features/quiz/history_tab.dart';
import 'package:numi_flutter/features/practice/practice_tab.dart';
import 'package:numi_flutter/features/settings/setting_tab.dart';
import 'package:numi_flutter/shared/widgets/score_progress_ring.dart';
import 'package:numi_flutter/features/classroom/widgets/student_class_search_content.dart';

part 'parent/assessment/helpers/parent_assessment_helpers.dart';
part 'parent/assessment/models/parent_assessment_entry.dart';
part 'parent/assessment/parent_assessment_tab.dart';
part 'parent/assessment/widgets/parent_assessment_chart_painter.dart';
part 'parent/assessment/widgets/parent_assessment_list_skeleton.dart';
part 'parent/assessment/widgets/parent_assessment_meta_item.dart';
part 'parent/assessment/widgets/parent_assessment_progress_chart.dart';
part 'parent/assessment/widgets/parent_assessment_score_badge.dart';
part 'parent/assessment/widgets/parent_assessment_search_field.dart';
part 'parent/assessment/widgets/parent_assessment_skeleton_pulse.dart';
part 'parent/assessment/widgets/parent_assessment_state_card.dart';
part 'parent/assessment/widgets/parent_assessment_tab_card.dart';
part 'parent/assessment/widgets/parent_practice_tab_banner.dart';
part 'parent/home/helpers/parent_child_dashboard_helpers.dart';
part 'parent/home/models/parent_child_summary.dart';
part 'parent/home/models/parent_home_entrance_builder.dart';
part 'parent/home/parent_home_child_dashboard.dart';
part 'parent/home/parent_home_completed_assessment.dart';
part 'parent/home/parent_home_first_assessment.dart';
part 'parent/home/parent_home_tab.dart';
part 'parent/home/widgets/parent_child_class_summary_card.dart';
part 'parent/home/widgets/parent_child_overview_content.dart';
part 'parent/home/widgets/parent_dashboard_section.dart';
part 'parent/home/widgets/parent_dashed_circle_painter.dart';
part 'parent/home/widgets/parent_game_suggestions_row.dart';
part 'parent/home/widgets/parent_home_error_card.dart';
part 'parent/home/widgets/parent_home_loading_card.dart';
part 'parent/home/widgets/parent_home_refresh_label.dart';
part 'parent/home/widgets/parent_learning_streak_card.dart';
part 'parent/home/widgets/parent_profile_dialog_action.dart';
part 'parent/home/widgets/parent_select_student_dialog.dart';
part 'parent/home/widgets/parent_streak_day_state.dart';
part 'parent/home/widgets/parent_streak_day.dart';
part 'parent/home/widgets/parent_teacher_message_item.dart';
part 'parent/home/widgets/parent_teacher_messages_list.dart';
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
part 'parent/shared/widgets/parent_completed_task_list_item.dart';
part 'parent/shared/widgets/parent_empty_task_line.dart';
part 'parent/shared/widgets/parent_home_entrance.dart';
part 'parent/shared/widgets/parent_pending_task_list_item.dart';
part 'parent/shared/widgets/parent_shimmer_transform.dart';
part 'parent/shared/widgets/parent_skeleton_block.dart';
part 'parent/shared/widgets/parent_skeleton_line.dart';
part 'parent/shared/widgets/parent_skeleton_shimmer.dart';
part 'parent/shared/widgets/parent_task_date_label.dart';
part 'parent/shared/widgets/parent_task_icon_box.dart';
part 'parent/shared/widgets/parent_task_meta_badges.dart';
part 'parent/shared/widgets/parent_task_meta_chip.dart';
part 'parent/shared/widgets/parent_task_score_ring.dart';
part 'parent/shared/widgets/parent_task_title.dart';
part 'student/student_dashboard.dart';
part 'student/classroom/student_classroom_tab.dart';
part 'student/classroom/widgets/student_classroom_card.dart';
part 'student/classroom/widgets/student_classroom_loading_region.dart';
part 'student/classroom/widgets/student_classroom_meta_row.dart';
part 'student/classroom/widgets/student_classroom_panel.dart';
part 'student/classroom/widgets/student_classroom_skeleton_block.dart';
part 'student/classroom/widgets/student_classroom_tab_card.dart';
part 'student/classroom/widgets/student_join_another_classroom_title.dart';
part 'student/home/helpers/student_home_view_helpers.dart';
part 'student/home/models/student_home_panel.dart';
part 'student/home/student_classroom_overview_home.dart';
part 'student/home/student_completed_assessment_home.dart';
part 'student/home/student_home_tab.dart';
part 'student/home/student_initial_assessment_home.dart';
part 'student/home/widgets/student_achievement_card.dart';
part 'student/home/widgets/student_achievement_panel.dart';
part 'student/home/widgets/student_achievements_header.dart';
part 'student/home/widgets/student_class_summary_card.dart';
part 'student/home/widgets/student_classroom_overview_entrance.dart';
part 'student/home/widgets/student_empty_panel.dart';
part 'student/home/widgets/student_error_panel.dart';
part 'student/home/widgets/student_game_suggestions_section.dart';
part 'student/home/widgets/student_home_tab_button.dart';
part 'student/home/widgets/student_home_tabs.dart';
part 'student/home/widgets/student_homework_panel.dart';
part 'student/home/widgets/student_homework_preview_card.dart';
part 'student/home/widgets/student_homework_status_chip.dart';
part 'student/home/widgets/student_join_classroom_button.dart';
part 'student/home/widgets/student_loading_panel.dart';
part 'student/home/widgets/student_message_panel.dart';
part 'student/home/widgets/student_teacher_message_card.dart';
part 'student/home/widgets/student_teacher_message_data.dart';
part 'student/home/widgets/student_teacher_messages.dart';
part 'student/invitations/student_invitation_list_screen.dart';
part 'student/invitations/widgets/student_invitation_card.dart';
part 'student/invitations/widgets/student_invitations_section.dart';
part 'student/invitations/widgets/student_invite_button.dart';
part 'student/invitations/widgets/student_invite_icon_button.dart';
part 'student/invitations/widgets/student_join_class_cta.dart';
part 'student/shared/widgets/student_home_sections_loading.dart';
part 'student/shared/widgets/student_inline_error_panel.dart';
part 'student/shared/widgets/student_section_header.dart';
part 'student/shared/widgets/student_state_card.dart';
part 'widgets/home_assessment_result_card.dart';
part 'widgets/home_role_dashboard.dart';

const _teal = Color(0xFF006762);
const _muted = Color(0xFF515F54);
const _deepInk = Color(0xFF253228);
const _studentHomeInvite = 'assets/images/student_home_invite.svg';
const _parentHomeAfterReviewBanner =
    'assets/images/parent_banner_after_review.jpg';
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
const _parentNoStudentMascot = 'assets/images/parent_no_student_mascot.png';
const _homeTeacherAvatarOne = 'assets/images/student_home_avatar.png';
const _homeTeacherAvatarTwo = 'assets/images/student_class_teacher.png';
const _homeFadeInDuration = Duration(milliseconds: 900);

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
      duration: _homeFadeInDuration,
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
