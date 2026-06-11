import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';
import '../../../../core/network/classroom_models.dart';
import '../../../../core/network/grade_models.dart';
import '../../../../core/network/profile_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/active_profile_session.dart';
import '../../data/classroom_api.dart';
import '../../data/otp_auth_api.dart';
import '../../data/grade_api.dart';
import '../../data/quiz_api.dart';
import '../tabs/history_tab.dart';
import '../tabs/review_tab.dart';
import '../tabs/setting_tab.dart';
import '../widgets/common_widgets.dart';
import '../widgets/profile_avatar_image.dart';
import '../widgets/student_class_search_content.dart';
import 'grade_selection_screen.dart';
import 'student_class_detail_screen.dart';
import 'teacher_classroom_screens.dart';

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
  });

  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final ProfileRole activeRole;
  final String? profileLoadError;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final VoidCallback onBack;
  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final GradeService _gradeService = GradeApi();
  late final AnimationController _parentHomeEntranceController;
  int _activeTab = 0;
  int _previousActiveTab = 0;
  int _openAddProfileRequestId = 0;
  bool _returnToReviewAfterProfileSave = false;
  int? _prefetchedGradeUserId;
  bool _isPrefetchingGrades = false;
  bool _isProfileMenuOpen = false;
  bool _isSwitchingProfile = false;
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
    if (oldWidget.activeRole != widget.activeRole &&
        _activeTab > _lastTabIndex(widget.activeRole)) {
      _previousActiveTab = _activeTab;
      _activeTab = 0;
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

  @override
  void dispose() {
    _parentHomeEntranceController.dispose();
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final layoutWidth = math.min(width, 430.0);
        final height = constraints.maxHeight;
        final viewportHeight = MediaQuery.sizeOf(context).height;
        final topInset = MediaQuery.paddingOf(context).top;
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        final scale = math.min(
            layoutWidth / _designWidth, viewportHeight / _designHeight);
        final studentName = _displayProfileName(
          context,
          widget.activeProfile,
          widget.activeRole,
        );

        double s(double value) => value * scale;
        final navHeight = s(88) + bottomInset;
        final headerHeight = s(98) + topInset;
        final showHeader =
            widget.activeRole != ProfileRole.teacher && _activeTab == 0;
        final switchableProfiles = widget.profiles
            .where(
              (profile) =>
                  ActiveProfileSession.profileStableId(profile) !=
                  ActiveProfileSession.profileStableId(widget.activeProfile),
            )
            .toList(growable: false);
        final profileMenuWidth = _profileMenuWidth(
          context,
          switchableProfiles,
          scale,
          layoutWidth - s(40),
        );

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(child: _HomeBackground()),
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          for (final child in previousChildren)
                            Positioned.fill(child: child),
                          if (currentChild != null)
                            Positioned.fill(child: currentChild),
                        ],
                      );
                    },
                    transitionBuilder: (child, animation) {
                      final isMovingRight = _activeTab > _previousActiveTab;
                      final beginX = isMovingRight ? 0.035 : -0.035;
                      final offset = Tween<Offset>(
                        begin: Offset(beginX, 0),
                        end: Offset.zero,
                      ).animate(animation);

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offset, child: child),
                      );
                    },
                    child: _TabContent(
                      key: ValueKey(
                        '$_activeTab-${ActiveProfileSession.profileStableId(widget.activeProfile)}',
                      ),
                      activeTab: _activeTab,
                      user: widget.user,
                      profiles: widget.profiles,
                      activeProfile: widget.activeProfile,
                      activeRole: widget.activeRole,
                      profileLoadError: widget.profileLoadError,
                      onRefreshProfiles: widget.onRefreshProfiles,
                      onActivateProfile: widget.onActivateProfile,
                      initialGrades: _prefetchedGrades,
                      gradeService: _gradeService,
                      onLogout: widget.onLogout,
                      onAddProfileFromReview: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _previousActiveTab = _activeTab;
                          _activeTab =
                              widget.activeRole == ProfileRole.student ? 4 : 3;
                          _returnToReviewAfterProfileSave = true;
                          _openAddProfileRequestId++;
                        });
                      },
                      onProfileSaved: () {
                        if (!_returnToReviewAfterProfileSave) {
                          return;
                        }

                        setState(() {
                          _previousActiveTab = _activeTab;
                          _activeTab =
                              widget.activeRole == ProfileRole.student ? 2 : 1;
                          _returnToReviewAfterProfileSave = false;
                        });
                      },
                      openAddProfileRequestId: _openAddProfileRequestId,
                      onCompleteTeacherProfile: _openTeacherProfileForm,
                      onOpenClassroomTab: () {
                        setState(() {
                          _previousActiveTab = _activeTab;
                          _activeTab = 1;
                        });
                      },
                      parentHomeEntrance: _parentHomeEntranceController,
                      bottomPadding: navHeight + s(14),
                      headerHeight: showHeader ? headerHeight : 0,
                      scale: scale,
                    ),
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
                      onProfileTap: switchableProfiles.isEmpty
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              setState(
                                () => _isProfileMenuOpen = !_isProfileMenuOpen,
                              );
                            },
                    ),
                  ),
                if (showHeader &&
                    _isProfileMenuOpen &&
                    switchableProfiles.isNotEmpty)
                  Positioned(
                    left: s(20),
                    top: headerHeight - s(29),
                    width: profileMenuWidth,
                    child: _HomeProfileMenu(
                      profiles: switchableProfiles,
                      scale: scale,
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
                    activeIndex: _activeTab,
                    activeRole: widget.activeRole,
                    user: widget.user,
                    onTabSelected: (index) {
                      if (index == _activeTab) {
                        HapticFeedback.selectionClick();
                        return;
                      }

                      HapticFeedback.lightImpact();
                      if (widget.activeRole == ProfileRole.parent &&
                          index == 0) {
                        _playParentHomeEntrance();
                      }
                      setState(() {
                        _previousActiveTab = _activeTab;
                        _activeTab = index;
                      });
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
    );
  }

  int _lastTabIndex(ProfileRole role) {
    return role == ProfileRole.parent ? 3 : 4;
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

  double _profileMenuWidth(
    BuildContext context,
    List<StudentProfile> profiles,
    double scale,
    double maxWidth,
  ) {
    final textStyle = TextStyle(
      fontSize: 15 * scale,
      fontWeight: FontWeight.w900,
    );
    var longestTextWidth = 0.0;

    for (final profile in profiles) {
      final name = _compactHomeProfileName(
        _profileDisplayName(context, profile),
      );
      final painter = TextPainter(
        text: TextSpan(text: name, style: textStyle),
        maxLines: 1,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      longestTextWidth = math.max(longestTextWidth, painter.width);
    }

    final contentWidth =
        (14 * 2 + 42 + 12) * scale + longestTextWidth + 8 * scale;
    return contentWidth.clamp(150 * scale, maxWidth);
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

class _TabContent extends StatelessWidget {
  const _TabContent({
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
    required this.onLogout,
    required this.onAddProfileFromReview,
    required this.onProfileSaved,
    required this.openAddProfileRequestId,
    required this.onCompleteTeacherProfile,
    required this.onOpenClassroomTab,
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
  final VoidCallback onLogout;
  final VoidCallback onAddProfileFromReview;
  final VoidCallback onProfileSaved;
  final int openAddProfileRequestId;
  final Future<void> Function() onCompleteTeacherProfile;
  final VoidCallback onOpenClassroomTab;
  final Animation<double> parentHomeEntrance;
  final double bottomPadding;
  final double headerHeight;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = EdgeInsets.only(
      left: 24 * scale,
      right: 24 * scale,
      top: headerHeight + (activeTab == 0 ? 0 : 24 * scale),
      bottom: bottomPadding,
    );

    return switch (activeRole) {
      ProfileRole.student => _buildStudentContent(horizontalPadding),
      ProfileRole.parent => _buildStudentContent(horizontalPadding),
      ProfileRole.teacher => _buildTeacherContent(),
    };
  }

  Widget _buildTeacherContent() {
    if (activeTab == 0) {
      return TeacherHomeTab(
        user: user,
        activeProfile: activeProfile,
        bottomPadding: bottomPadding,
        scale: scale,
        onCompleteProfile: onCompleteTeacherProfile,
        onOpenClassroomTab: onOpenClassroomTab,
      );
    }

    if (activeTab == 1) {
      return TeacherClassroomTab(
        user: user,
        activeProfile: activeProfile,
        bottomPadding: bottomPadding,
        scale: scale,
      );
    }

    if (activeTab == 2) {
      return TeacherStudyTab(
        user: user,
        activeProfile: activeProfile,
        bottomPadding: bottomPadding,
        scale: scale,
      );
    }

    if (activeTab == 3) {
      return const SizedBox.shrink();
    }

    if (activeTab == 4) {
      return SettingTab(
        user: user,
        profiles: profiles,
        activeProfile: activeProfile,
        profileLoadError: profileLoadError,
        onLogout: onLogout,
        onActivateProfile: onActivateProfile,
        onRefreshProfiles: onRefreshProfiles,
        onProfileSaved: onProfileSaved,
        openAddProfileRequestId: openAddProfileRequestId,
        bottomPadding: bottomPadding,
        scale: scale,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStudentContent(EdgeInsets horizontalPadding) {
    if (activeTab == 0) {
      return _StudentHomeContent(
        padding: horizontalPadding,
        scale: scale,
        user: user,
        profiles: profiles,
        activeProfile: activeProfile,
        activeRole: activeRole,
        initialGrades: initialGrades,
        gradeService: gradeService,
        onOpenClassroomTab: onOpenClassroomTab,
        onRefreshProfiles: onRefreshProfiles,
        onActivateProfile: onActivateProfile,
        onProfileSaved: onProfileSaved,
        parentHomeEntrance: parentHomeEntrance,
      );
    }

    if (activeRole == ProfileRole.student && activeTab == 1) {
      return _StudentClassroomTab(
        bottomPadding: bottomPadding,
        scale: scale,
        user: user,
        activeProfile: activeProfile,
      );
    }

    final settingsTab = activeRole == ProfileRole.student ? 4 : 3;
    final reviewTab = activeRole == ProfileRole.student ? 2 : 1;
    final historyTab = activeRole == ProfileRole.student ? 3 : 2;

    if (activeTab == settingsTab) {
      return SettingTab(
        user: user,
        profiles: profiles,
        activeProfile: activeProfile,
        profileLoadError: profileLoadError,
        onLogout: onLogout,
        onActivateProfile: onActivateProfile,
        onRefreshProfiles: onRefreshProfiles,
        onProfileSaved: onProfileSaved,
        openAddProfileRequestId: openAddProfileRequestId,
        bottomPadding: bottomPadding,
        scale: scale,
      );
    }

    if (activeTab == reviewTab) {
      return ReviewTab(
        user: user,
        activeProfile: activeProfile,
        profileLoadError: profileLoadError,
        onRefreshProfiles: onRefreshProfiles,
        onAddProfile: onAddProfileFromReview,
        bottomPadding: bottomPadding,
        scale: scale,
      );
    }

    if (activeTab == historyTab) {
      return HistoryTab(
        user: user,
        activeProfile: activeProfile,
        bottomPadding: bottomPadding,
        scale: scale,
      );
    }

    return const SizedBox.shrink();
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
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final contentHeight = height - topInset;

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
                                  fontSize: contentHeight * 0.10,
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
                                        fontSize: contentHeight * 0.18,
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

class _HomeProfileMenu extends StatelessWidget {
  const _HomeProfileMenu({
    required this.profiles,
    required this.scale,
    required this.onSelect,
  });

  final List<StudentProfile> profiles;
  final double scale;
  final ValueChanged<StudentProfile> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(10 * scale),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 240 * scale),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 8 * scale),
          itemCount: profiles.length,
          separatorBuilder: (_, __) => SizedBox(height: 2 * scale),
          itemBuilder: (context, index) {
            final profile = profiles[index];
            final name = _compactHomeProfileName(
              _profileDisplayName(context, profile),
            );

            return InkWell(
              onTap: () => onSelect(profile),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 7 * scale,
                ),
                child: Row(
                  children: [
                    ProfileAvatarImage(
                      size: 42 * scale,
                      avatarKey: profile.avatarKey,
                      avatarUrl: profile.avatarUrl,
                    ),
                    SizedBox(width: 12 * scale),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          name,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            color: const Color(0xFF002B6A),
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

String _profileDisplayName(BuildContext context, StudentProfile profile) {
  if (profile.name?.trim().isNotEmpty == true) {
    return profile.name!.trim();
  }
  if (profile.profileCode?.trim().isNotEmpty == true) {
    return profile.profileCode!.trim();
  }
  return context.getText(AppKeys.student);
}

String _compactHomeProfileName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.length <= 2) {
    return parts.join(' ');
  }
  return '${parts.first} ${parts.last}';
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
class _TestHeroCard extends StatelessWidget {
  const _TestHeroCard({
    required this.height,
    required this.scale,
    required this.user,
    required this.initialGrades,
    required this.gradeService,
    required this.profileId,
  });

  final double height;
  final double scale;
  final LoginUser? user;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final int? profileId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48 * scale),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF29CDC3),
            Color(0xFF9AC8B6),
            Color(0xFFF2E6C8),
          ],
          stops: [0, 0.55, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00504B).withValues(alpha: 0.25),
            blurRadius: 30 * scale,
            offset: Offset(0, 18 * scale),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            right: 40 * scale,
            top: 40 * scale,
            child: _HeroMathGlyph(scale: scale),
          ),
          Positioned(
            left: 24 * scale,
            bottom: 58 * scale,
            child: Transform.rotate(
              angle: -0.16,
              child: _HeroTriangleGhost(scale: scale),
            ),
          ),
          Positioned(
            top: 58 * scale,
            left: 24 * scale,
            right: 24 * scale,
            child: Column(
              children: [
                Text(
                  context.getText(AppKeys.assessment),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 15 * scale),
                Text(
                  context.getText(AppKeys.assessmentDescription),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w700,
                    height: 1.62,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 176 * scale,
            child: _MascotStage(scale: scale),
          ),
          Positioned(
            bottom: 28 * scale,
            left: 24 * scale,
            right: 24 * scale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _HeroButton(
                    scale: scale,
                    label: context.getText(AppKeys.startNow),
                    icon: Icons.rocket_launch_outlined,
                    onTap: () {
                      _openGradeSelection(context, quizPurposeAssessment);
                    },
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: _HeroButton(
                    scale: scale,
                    label: context.getText(AppKeys.practice),
                    icon: Icons.school_outlined,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF34D36F), Color(0xFF0C8F4A)],
                    ),
                    depthColor: const Color(0xFF075E31),
                    shadowColor: const Color(0xFF0C8F4A),
                    onTap: () {
                      _openGradeSelection(context, quizPurposePractice);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openGradeSelection(BuildContext context, String quizPurpose) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GradeSelectionScreen(
          user: user,
          initialGrades: initialGrades,
          gradeService: gradeService,
          quizPurpose: quizPurpose,
          profileId: profileId,
        ),
      ),
    );
  }
}

class _MascotStage extends StatelessWidget {
  const _MascotStage({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 216 * scale,
      height: 202 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 2 * scale,
            child: Container(
              width: 142 * scale,
              height: 18 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF253228).withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF253228).withValues(alpha: 0.06),
                    blurRadius: 14 * scale,
                    spreadRadius: 1 * scale,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: -18 * scale,
            top: 18 * scale,
            child: Transform.rotate(
              angle: 0.11,
              child: _EquationChip(
                text: '5 + 3 = 8',
                foreground: _teal,
                background: Colors.white,
                scale: scale,
              ),
            ),
          ),
          Positioned(
            left: -18 * scale,
            bottom: 50 * scale,
            child: Transform.rotate(
              angle: -0.18,
              child: _EquationChip(
                text: '2 × 2 = 4',
                foreground: const Color(0xFF832800),
                background: const Color(0xFFFFC4B1),
                scale: scale,
              ),
            ),
          ),
          Image.asset(
            'assets/images/home_test_mascot.png',
            width: 176 * scale,
            height: 176 * scale,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _EquationChip extends StatelessWidget {
  const _EquationChip({
    required this.text,
    required this.foreground,
    required this.background,
    required this.scale,
  });

  final String text;
  final Color foreground;
  final Color background;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8 * scale,
            offset: Offset(0, 3 * scale),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14 * scale,
          vertical: 10 * scale,
        ),
        child: Text(
          text,
          maxLines: 1,
          style: TextStyle(
            color: foreground,
            fontSize: 19 * scale,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _HeroButton extends StatefulWidget {
  const _HeroButton({
    required this.scale,
    required this.label,
    required this.icon,
    required this.onTap,
    this.gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFF9F7D), Color(0xFFA03A0F)],
    ),
    this.depthColor = const Color(0xFF621C00),
    this.shadowColor = const Color(0xFFA03A0F),
  });

  final double scale;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Gradient gradient;
  final Color depthColor;
  final Color shadowColor;

  @override
  State<_HeroButton> createState() => _HeroButtonState();
}

class _HeroButtonState extends State<_HeroButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final height = 42 * widget.scale;
    final depth = 6 * widget.scale;
    final pressOffset = pressed ? depth : 0.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) => setState(() => pressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: SizedBox(
        height: height + 8 * widget.scale,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              top: depth,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 90),
                opacity: pressed ? 0.25 : 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.depthColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: widget.shadowColor.withValues(alpha: 0.24),
                        blurRadius: 12 * widget.scale,
                        offset: Offset(0, 8 * widget.scale),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(0, pressOffset, 0),
              height: height,
              padding: EdgeInsets.only(
                left: 18 * widget.scale,
                right: 14 * widget.scale,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: widget.gradient,
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.white.withValues(alpha: pressed ? 0.22 : 0.45),
                    blurRadius: 1,
                    offset: Offset(0, 1 * widget.scale),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15 * widget.scale,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * widget.scale),
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 21 * widget.scale,
                  ),
                ],
              ),
            ),
            Positioned.fill(
              top: depth,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 90),
                  opacity: pressed ? 0.16 : 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StudentHomePanel { homework, classroom, achievement }

class _StudentHomeContent extends StatefulWidget {
  const _StudentHomeContent({
    required this.padding,
    required this.scale,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.activeRole,
    required this.initialGrades,
    required this.gradeService,
    required this.onOpenClassroomTab,
    required this.onRefreshProfiles,
    required this.onActivateProfile,
    required this.onProfileSaved,
    required this.parentHomeEntrance,
  });

  final EdgeInsets padding;
  final double scale;
  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final ProfileRole activeRole;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final VoidCallback onOpenClassroomTab;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final VoidCallback onProfileSaved;
  final Animation<double> parentHomeEntrance;

  @override
  State<_StudentHomeContent> createState() => _StudentHomeContentState();
}

class _StudentHomeContentState extends State<_StudentHomeContent> {
  final ClassroomService _classroomService = ClassroomApi();
  final _StudentHomePanel _activePanel = _StudentHomePanel.homework;
  int? _loadedProfileId;
  bool _isLoadingClassrooms = false;
  bool _isLoadingInvitations = false;
  bool _hasLoadedClassrooms = false;
  bool _hasLoadedInvitations = false;
  String? _classroomError;
  String? _invitationError;
  List<ClassroomModel> _classrooms = const <ClassroomModel>[];
  List<ClassroomInvitation> _invitations = const <ClassroomInvitation>[];
  final Set<int> _processingInvitationClassIds = <int>{};

  @override
  void initState() {
    super.initState();
    if (widget.activeRole == ProfileRole.student) {
      _loadClassrooms();
    }
    _loadInvitations();
  }

  @override
  void didUpdateWidget(covariant _StudentHomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldProfileId = ActiveProfileSession.profileStableId(
      oldWidget.activeProfile,
    );
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final roleChanged = oldWidget.activeRole != widget.activeRole;
    if (oldProfileId != profileId || roleChanged) {
      _loadedProfileId = null;
      _classrooms = const <ClassroomModel>[];
      _invitations = const <ClassroomInvitation>[];
      _hasLoadedClassrooms = false;
      _hasLoadedInvitations = false;
      _classroomError = null;
      _invitationError = null;
      if (widget.activeRole == ProfileRole.student) {
        _loadClassrooms();
      }
      _loadInvitations();
    }
  }

  Future<void> _loadClassrooms() async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0 || _isLoadingClassrooms) {
      return;
    }
    if (_loadedProfileId == profileId && _classrooms.isNotEmpty) {
      return;
    }

    setState(() {
      _isLoadingClassrooms = true;
      _classroomError = null;
    });

    try {
      final classrooms = await _classroomService.listMyJoinedClassrooms(
        profileId: profileId,
      );
      if (!mounted ||
          ActiveProfileSession.profileStableId(widget.activeProfile) !=
              profileId) {
        return;
      }

      setState(() {
        _loadedProfileId = profileId;
        _hasLoadedClassrooms = true;
        _classrooms = classrooms;
      });
    } catch (_) {
      if (!mounted ||
          ActiveProfileSession.profileStableId(widget.activeProfile) !=
              profileId) {
        return;
      }

      setState(() {
        _loadedProfileId = profileId;
        _hasLoadedClassrooms = true;
        _classroomError = context.readText(AppKeys.studentClassroomLoadFailed);
        _classrooms = const <ClassroomModel>[];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingClassrooms = false);
      } else {
        _isLoadingClassrooms = false;
      }
    }
  }

  Future<void> _loadInvitations() async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0 || _isLoadingInvitations) {
      return;
    }

    setState(() {
      _isLoadingInvitations = true;
      _invitationError = null;
    });

    try {
      final invitations = await _classroomService.listMyPendingInvitations(
        profileId: profileId,
      );
      if (!mounted ||
          ActiveProfileSession.profileStableId(widget.activeProfile) !=
              profileId) {
        return;
      }

      setState(() {
        _hasLoadedInvitations = true;
        _invitations = invitations;
      });
    } catch (_) {
      if (!mounted ||
          ActiveProfileSession.profileStableId(widget.activeProfile) !=
              profileId) {
        return;
      }

      setState(() {
        _hasLoadedInvitations = true;
        _invitationError =
            context.readText(AppKeys.studentInvitationLoadFailed);
        _invitations = const <ClassroomInvitation>[];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingInvitations = false);
      } else {
        _isLoadingInvitations = false;
      }
    }
  }

  Future<void> _handleInvitation(
    ClassroomInvitation invitation, {
    required bool accept,
  }) async {
    if (!await _allowClassroomActionForActiveRole()) {
      return;
    }

    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final classroomId = invitation.stableClassroomId;
    if (profileId == null || profileId <= 0 || classroomId == null) {
      return;
    }
    final inviterProfileId = invitation.inviterProfileId ?? profileId;

    setState(() => _processingInvitationClassIds.add(classroomId));
    try {
      if (accept) {
        await _classroomService.acceptInvitation(
          inviteeProfileId: profileId,
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
        );
      } else {
        await _classroomService.rejectInvitation(
          inviteeProfileId: profileId,
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
        );
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.readText(
                accept
                    ? AppKeys.studentInvitationAcceptSuccess
                    : AppKeys.studentInvitationRejectSuccess,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      await _loadInvitations();
      if (accept) {
        _loadedProfileId = null;
        await _loadClassrooms();
      }
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _processingInvitationClassIds.remove(classroomId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final isLoadingHomeSections = profileId != null &&
        profileId > 0 &&
        (!_hasLoadedInvitations ||
            (widget.activeRole == ProfileRole.student &&
                !_hasLoadedClassrooms));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.activeRole == ProfileRole.parent)
            _HomePopIn(
              animation: widget.parentHomeEntrance,
              interval: const Interval(0, 0.62),
              beginOffset: const Offset(-18, 14),
              beginRotation: -0.024,
              beginScale: 0.92,
              child: _StudentFigmaHeroCard(
                onAssessmentTap: () =>
                    _openGradeSelection(quizPurposeAssessment),
              ),
            )
          else
            _StudentFigmaHeroCard(
              onAssessmentTap: () => _openGradeSelection(quizPurposeAssessment),
            ),
          const SizedBox(height: 22),
          if (widget.activeRole == ProfileRole.parent)
            _HomePopIn(
              animation: widget.parentHomeEntrance,
              interval: const Interval(0.3, 1),
              beginOffset: const Offset(18, 16),
              beginRotation: 0.024,
              beginScale: 0.9,
              child: const _ParentWelcomeMapCard(),
            )
          else if (isLoadingHomeSections)
            const _StudentHomeSectionsLoading()
          else ...[
            _StudentInvitationsSection(
              invitations: _invitations,
              isLoading: _isLoadingInvitations,
              error: _invitationError,
              processingClassroomIds: _processingInvitationClassIds,
              showJoinClassroom: widget.activeRole == ProfileRole.student &&
                  _classrooms.isEmpty,
              onJoinClassroom: widget.activeRole == ProfileRole.student
                  ? widget.onOpenClassroomTab
                  : _handleParentClassroomEntry,
              onViewAll: _openAllInvitations,
              onAccept: (invitation) => _handleInvitation(
                invitation,
                accept: true,
              ),
              onReject: (invitation) => _handleInvitation(
                invitation,
                accept: false,
              ),
              onRetry: _loadInvitations,
            ),
            if (widget.activeRole == ProfileRole.student) ...[
              const SizedBox(height: 11),
              _StudentClassGridSection(
                classrooms: _classrooms,
                isLoading: _isLoadingClassrooms,
                error: _classroomError,
                onOpenClassroom: _openClassDetail,
                onViewAll: widget.onOpenClassroomTab,
              ),
            ],
            const SizedBox(height: 20),
            const _HomeTeacherMessages(),
          ],
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildPanel(BuildContext context) {
    return switch (_activePanel) {
      _StudentHomePanel.homework => _HomeworkPanel(
          key: const ValueKey(_StudentHomePanel.homework),
          scale: widget.scale,
        ),
      _StudentHomePanel.classroom => _StudentClassroomPanel(
          key: const ValueKey(_StudentHomePanel.classroom),
          scale: widget.scale,
          classrooms: _classrooms,
          isLoading: _isLoadingClassrooms,
          error: _classroomError,
          onRetry: _loadClassrooms,
          onJoinClassroom: widget.activeRole == ProfileRole.student
              ? widget.onOpenClassroomTab
              : _handleParentClassroomEntry,
        ),
      _StudentHomePanel.achievement => _AchievementPanel(
          key: const ValueKey(_StudentHomePanel.achievement),
          scale: widget.scale,
        ),
    };
  }

  Future<void> _handleParentClassroomEntry() async {
    await _allowClassroomActionForActiveRole();
  }

  Future<void> _openAllInvitations() async {
    if (!await _allowClassroomActionForActiveRole()) {
      return;
    }
    if (!mounted) {
      return;
    }

    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.readText(AppKeys.studentMissingProfileId)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.selectionClick();
    final acceptedInvitation = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _StudentInvitationListScreen(
          profileId: profileId,
          classroomService: _classroomService,
          initialInvitations: _invitations,
        ),
      ),
    );
    await _loadInvitations();
    if (acceptedInvitation == true) {
      _loadedProfileId = null;
      await _loadClassrooms();
    }
  }

  Future<bool> _allowClassroomActionForActiveRole() async {
    if (widget.activeRole != ProfileRole.parent) {
      return true;
    }

    if (_studentProfiles.isEmpty) {
      await widget.onRefreshProfiles();
      if (!mounted) {
        return false;
      }
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) {
        return false;
      }
    }

    if (_studentProfiles.isNotEmpty) {
      final shouldSwitch = await _showParentSwitchStudentDialog();
      if (shouldSwitch == true && mounted) {
        await _openProfileSwitch();
      }
      return false;
    }

    final shouldCreateStudent = await _showParentNoStudentDialog();
    if (!mounted) {
      return false;
    }
    if (shouldCreateStudent == true) {
      await _openCreateStudentProfile();
    }
    return false;
  }

  List<StudentProfile> get _studentProfiles {
    return widget.profiles
        .where((profile) =>
            ProfileRole.fromProfile(profile) == ProfileRole.student)
        .toList();
  }

  Future<void> _openProfileSwitch() async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Material(
          color: Colors.white,
          child: SafeArea(
            child: SettingTab.page(
              user: widget.user,
              profiles: widget.profiles,
              activeProfile: widget.activeProfile,
              profileLoadError: null,
              onLogout: () {},
              onActivateProfile: widget.onActivateProfile,
              onRefreshProfiles: widget.onRefreshProfiles,
              onProfileSaved: widget.onProfileSaved,
              bottomPadding: 0,
              scale: widget.scale,
              initialView: SettingPageView.profile,
              isPushedPage: true,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateStudentProfile() async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Material(
          color: Colors.white,
          child: SafeArea(
            child: SettingTab.page(
              user: widget.user,
              profiles: widget.profiles,
              activeProfile: widget.activeProfile,
              profileLoadError: null,
              onLogout: () {},
              onActivateProfile: widget.onActivateProfile,
              onRefreshProfiles: widget.onRefreshProfiles,
              onProfileSaved: widget.onProfileSaved,
              bottomPadding: 0,
              scale: widget.scale,
              initialView: SettingPageView.profile,
              isPushedPage: true,
              openAddProfileOnStart: true,
            ),
          ),
        ),
      ),
    );
    await widget.onRefreshProfiles();
  }

  Future<bool?> _showParentSwitchStudentDialog() {
    HapticFeedback.selectionClick();
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            context.getText(AppKeys.parentSwitchStudentTitle),
            style: const TextStyle(
              color: Color(0xFF001741),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          content: Text(
            context.getText(AppKeys.parentSwitchStudentMessage),
            style: const TextStyle(
              color: Color(0xFF444650),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.getText(AppKeys.cancel)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF008080),
              ),
              child: Text(
                context.getText(AppKeys.parentSwitchStudentAction),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showParentNoStudentDialog() {
    HapticFeedback.selectionClick();
    return showDialog<bool>(
      context: context,
      barrierColor: const Color(0xFF001741).withValues(alpha: 0.40),
      builder: (_) => const _ParentNoStudentDialog(),
    );
  }

  void _openGradeSelection(String quizPurpose) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GradeSelectionScreen(
          user: widget.user,
          initialGrades: widget.initialGrades,
          gradeService: widget.gradeService,
          quizPurpose: quizPurpose,
          profileId: ActiveProfileSession.profileStableId(
            widget.activeProfile,
          ),
          initialGradeId: _profileGradeId(widget.activeProfile),
          initialGradeLabel: widget.activeProfile?.grade?.label,
        ),
      ),
    );
  }

  Future<void> _openClassDetail(ClassroomModel classroom) async {
    if (!await _allowClassroomActionForActiveRole()) {
      return;
    }
    if (!mounted) {
      return;
    }

    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final classroomId = classroom.stableId;
    if (profileId == null || profileId <= 0 || classroomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.readText(AppKeys.teacherClassOpenFailed)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.selectionClick();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => StudentClassDetailScreen(
          classroomId: classroomId,
          profileId: profileId,
          initialClassroom: classroom,
          classroomService: _classroomService,
        ),
      ),
    );
  }
}

int? _profileGradeId(StudentProfile? profile) =>
    profile?.grade?.gradeId ?? profile?.grade?.id ?? profile?.gradeId;

class _StudentInvitationsSection extends StatelessWidget {
  const _StudentInvitationsSection({
    required this.invitations,
    required this.isLoading,
    required this.error,
    required this.processingClassroomIds,
    required this.showJoinClassroom,
    required this.onJoinClassroom,
    required this.onViewAll,
    required this.onAccept,
    required this.onReject,
    required this.onRetry,
  });

  final List<ClassroomInvitation> invitations;
  final bool isLoading;
  final String? error;
  final Set<int> processingClassroomIds;
  final bool showJoinClassroom;
  final VoidCallback onJoinClassroom;
  final VoidCallback onViewAll;
  final ValueChanged<ClassroomInvitation> onAccept;
  final ValueChanged<ClassroomInvitation> onReject;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final invitation = invitations.isNotEmpty ? invitations.first : null;
    final showInvitationPreview =
        isLoading || error != null || invitation != null;
    if (!showInvitationPreview && !showJoinClassroom) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showInvitationPreview) ...[
            _StudentFigmaSectionHeader(
              title: context.getText(AppKeys.studentClassInvitations),
              actionLabel: context.formatText(
                AppKeys.studentViewAllInvitations,
                {'count': invitations.length},
              ),
              onAction: invitation == null ? null : onViewAll,
            ),
            const SizedBox(height: 10),
            if (isLoading && invitation == null)
              const SizedBox(
                height: 77,
                child: Center(
                  child: CircularProgressIndicator(color: _teal),
                ),
              )
            else if (error != null && invitation == null)
              _StudentInlineErrorPanel(
                message: error!,
                onRetry: onRetry,
              )
            else if (invitation != null)
              _StudentInvitationCard(
                invitation: invitation,
                isProcessing: processingClassroomIds.contains(
                  invitation.stableClassroomId,
                ),
                compactActions: true,
                onAccept: () => onAccept(invitation),
                onReject: () => onReject(invitation),
              ),
            const SizedBox(height: 6),
          ],
          if (showJoinClassroom) _StudentJoinClassCta(onTap: onJoinClassroom),
        ],
      ),
    );
  }
}

class _StudentHomeSectionsLoading extends StatelessWidget {
  const _StudentHomeSectionsLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: _teal),
            const SizedBox(height: 14),
            Text(
              context.getText(AppKeys.loading),
              style: const TextStyle(
                color: Color(0xFF30333A),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentNoStudentDialog extends StatelessWidget {
  const _ParentNoStudentDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: 303,
            padding: const EdgeInsets.fromLTRB(25, 32, 25, 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 192,
                      height: 192,
                      decoration: BoxDecoration(
                        color: const Color(0xFFAA2A6C).withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFAA2A6C).withValues(alpha: 0.16),
                            blurRadius: 30,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      _parentNoStudentMascot,
                      width: 220,
                      height: 198,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  context.getText(AppKeys.parentNoStudentTitle),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF001741),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.getText(AppKeys.parentNoStudentMessage),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF444650),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFAA2A6C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      context.getText(AppKeys.parentCreateStudentNow),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFAA2A6C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      context.getText(AppKeys.parentCreateStudentLater),
                      style: const TextStyle(
                        color: Color(0xFFAA2A6C),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentInlineErrorPanel extends StatelessWidget {
  const _StudentInlineErrorPanel({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF444650),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(context.getText(AppKeys.studentClassSearchRetry)),
          ),
        ],
      ),
    );
  }
}

class _StudentFigmaSectionHeader extends StatelessWidget {
  const _StudentFigmaSectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final action = Text(
      actionLabel,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFFBC3B14),
        fontSize: 14,
        fontWeight: FontWeight.w900,
        decoration: TextDecoration.underline,
        height: 1.2,
        letterSpacing: 0,
      ),
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF001741),
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (onAction == null)
          action
        else
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onAction!();
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: action,
            ),
          ),
      ],
    );
  }
}

class _StudentInvitationCard extends StatelessWidget {
  const _StudentInvitationCard({
    required this.invitation,
    required this.isProcessing,
    this.compactActions = false,
    required this.onAccept,
    required this.onReject,
  });

  final ClassroomInvitation invitation;
  final bool isProcessing;
  final bool compactActions;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final classroom = invitation.classroom;
    final title = classroom?.name?.trim().isNotEmpty == true
        ? classroom!.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final inviterName = invitation.inviterName?.trim();
    final subtitle = inviterName != null && inviterName.isNotEmpty
        ? context.formatText(
            AppKeys.studentInviteSubtitle,
            {'name': inviterName},
          )
        : context.getText(AppKeys.studentInviteSubtitleFallback);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: compactActions
          ? _buildCompact(context, title, subtitle)
          : Column(
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      _studentHomeInvite,
                      width: 36,
                      height: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF181C1E),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF444650),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                if (isProcessing)
                  const SizedBox(
                    height: 27,
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: _teal,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _StudentInviteButton(
                          label: context.getText(AppKeys.accept),
                          color: const Color(0xFF38898C),
                          onTap: onAccept,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StudentInviteButton(
                          label: context.getText(AppKeys.reject),
                          color: const Color(0xFFF37850),
                          onTap: onReject,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }

  Widget _buildCompact(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF001741),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF001741).withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (isProcessing)
          const SizedBox(
            width: 56,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: _teal,
                  strokeWidth: 2,
                ),
              ),
            ),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StudentInviteIconButton(
                asset: _studentParentHomeAcceptIcon,
                label: context.getText(AppKeys.accept),
                onTap: onAccept,
              ),
              const SizedBox(width: 8),
              _StudentInviteIconButton(
                asset: _studentParentHomeRejectIcon,
                label: context.getText(AppKeys.reject),
                onTap: onReject,
              ),
            ],
          ),
      ],
    );
  }
}

class _StudentInviteIconButton extends StatelessWidget {
  const _StudentInviteIconButton({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(999),
        child: Image.asset(asset, width: 25, height: 25),
      ),
    );
  }
}

class _StudentInviteButton extends StatelessWidget {
  const _StudentInviteButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 27,
      child: FilledButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _StudentFigmaHeroCard extends StatelessWidget {
  const _StudentFigmaHeroCard({required this.onAssessmentTap});

  final VoidCallback onAssessmentTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 225,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFFEDF7F6),
            Color(0xFFF7CFC3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -14,
            right: -14,
            bottom: -48,
            child: Opacity(
              opacity: 0.70,
              child: Image.asset(
                _studentParentHomeHeroBg,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 35,
            right: 35,
            top: 23,
            child: Text(
              context.getText(AppKeys.homeHeroTitle),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF357476),
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.5,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Positioned(
            left: 35,
            right: 35,
            top: 65,
            child: Text(
              context.getText(AppKeys.homeHeroSubtitle),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF001741),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
          ),
          Positioned(
            right: -10,
            top: 18,
            width: 80,
            child: Transform.rotate(
              angle: 0.785398,
              child: Text(
                context.getText(AppKeys.homeHeroTextbookLabel),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFD95F42),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          Positioned(
            right: -13,
            bottom: 0,
            width: 202,
            height: 135,
            child: Image.asset(_studentParentHomeHeroArt, fit: BoxFit.contain),
          ),
          Positioned(
            left: 9,
            bottom: 37,
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    context.getText(AppKeys.homeHeroPrompt),
                    style: const TextStyle(
                      color: Color(0xFF001741),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      height: 1.15,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                _HeroActionButton(
                  label: context.getText(AppKeys.homeHeroAssessment),
                  color: const Color(0xFFFB7651),
                  icon: _studentParentHomeAssessmentIcon,
                  onTap: onAssessmentTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentWelcomeMapCard extends StatelessWidget {
  const _ParentWelcomeMapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Image.asset(
        _parentHomeWelcomeMap,
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
      ),
    );
  }
}

class _HomePopIn extends StatelessWidget {
  const _HomePopIn({
    required this.child,
    required this.animation,
    required this.interval,
    required this.beginOffset,
    required this.beginRotation,
    this.beginScale = 0.92,
  });

  final Widget child;
  final Animation<double> animation;
  final Interval interval;
  final Offset beginOffset;
  final double beginRotation;
  final double beginScale;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: RepaintBoundary(child: child),
      builder: (context, child) {
        final intervalValue = interval.transform(animation.value);
        final fadeValue = Curves.easeOut.transform(intervalValue);
        final moveValue = Curves.easeOutCubic.transform(intervalValue);
        final scaleValue = Curves.easeOutBack.transform(intervalValue);

        return Opacity(
          opacity: fadeValue,
          child: Transform.translate(
            offset: Offset.lerp(beginOffset, Offset.zero, moveValue)!,
            child: Transform.rotate(
              angle: beginRotation * (1 - moveValue),
              child: Transform.scale(
                scale: beginScale + ((1 - beginScale) * scaleValue),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  const _HeroActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(width: 6),
            SvgPicture.asset(icon, width: 16, height: 16),
          ],
        ),
      ),
    );
  }
}

class _StudentJoinClassCta extends StatelessWidget {
  const _StudentJoinClassCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFAA2A6C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              _studentParentHomeJoinIcon,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 7),
            Text(
              context.getText(AppKeys.studentJoinClassroomUpper),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentClassGridSection extends StatelessWidget {
  const _StudentClassGridSection({
    required this.classrooms,
    required this.isLoading,
    required this.error,
    required this.onOpenClassroom,
    required this.onViewAll,
  });

  final List<ClassroomModel> classrooms;
  final bool isLoading;
  final String? error;
  final ValueChanged<ClassroomModel> onOpenClassroom;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final visibleClassrooms = classrooms.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StudentFigmaSectionHeader(
          title: context.getText(AppKeys.teacherYourClasses),
          actionLabel: context.formatText(
            AppKeys.studentViewAllClassrooms,
            {'count': classrooms.length},
          ),
          onAction: classrooms.isEmpty ? null : onViewAll,
        ),
        const SizedBox(height: 10),
        if (isLoading && classrooms.isEmpty)
          const _StudentFigmaStateCard(
            titleKey: AppKeys.loading,
            messageKey: AppKeys.studentClassroomLoadFailed,
          )
        else if (error != null && classrooms.isEmpty)
          _StudentFigmaStateCard(title: error!, messageKey: AppKeys.retry)
        else if (visibleClassrooms.isEmpty)
          const _StudentFigmaStateCard(
            titleKey: AppKeys.studentNoClassroomsTitle,
            messageKey: AppKeys.studentNoClassroomsMessage,
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 78,
            ),
            itemCount: visibleClassrooms.length,
            itemBuilder: (context, index) {
              return _StudentFigmaClassCard(
                classroom: visibleClassrooms[index],
                onTap: () => onOpenClassroom(visibleClassrooms[index]),
              );
            },
          ),
      ],
    );
  }
}

class _StudentFigmaStateCard extends StatelessWidget {
  const _StudentFigmaStateCard({
    this.title,
    this.titleKey,
    required this.messageKey,
  });

  final String? title;
  final String? titleKey;
  final String messageKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF2F8),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              _studentParentHomeClassThumb,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title ?? context.getText(titleKey!),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.getText(messageKey),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF002B6A).withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentFigmaClassCard extends StatelessWidget {
  const _StudentFigmaClassCard({
    required this.classroom,
    required this.onTap,
  });

  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = classroom.name?.trim().isNotEmpty == true
        ? classroom.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final teacher = classroom.teacherName?.trim().isNotEmpty == true
        ? classroom.teacherName!.trim()
        : context.getText(AppKeys.teacherFallback);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD7DCE5),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF002B6A).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF073E45),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                teacher,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF357476).withValues(alpha: 0.72),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTeacherMessages extends StatelessWidget {
  const _HomeTeacherMessages();

  @override
  Widget build(BuildContext context) {
    const messages = <_HomeTeacherMessageData>[
      _HomeTeacherMessageData(
        avatarAsset: _homeTeacherAvatarOne,
        teacherKey: AppKeys.homeMessageTeacherOne,
        classKey: AppKeys.homeMessageClassOne,
        timeKey: AppKeys.homeMessageTimeOne,
        studentKey: AppKeys.homeMessageStudentOne,
        bodyKey: AppKeys.homeMessageBodyOne,
        accentColor: Color(0xFFB52B70),
        badgeColor: Color(0xFFF1C6DB),
      ),
      _HomeTeacherMessageData(
        avatarAsset: _homeTeacherAvatarTwo,
        teacherKey: AppKeys.homeMessageTeacherTwo,
        classKey: AppKeys.homeMessageClassTwo,
        timeKey: AppKeys.homeMessageTimeTwo,
        studentKey: AppKeys.homeMessageStudentTwo,
        bodyKey: AppKeys.homeMessageBodyTwo,
        accentColor: Color(0xFF002B6A),
        badgeColor: Color(0xFFC8D6F2),
      ),
    ];

    return Column(
      children: [
        for (var index = 0; index < messages.length; index++) ...[
          _HomeTeacherMessageCard(data: messages[index]),
          if (index != messages.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _HomeTeacherMessageData {
  const _HomeTeacherMessageData({
    required this.avatarAsset,
    required this.teacherKey,
    required this.classKey,
    required this.timeKey,
    required this.studentKey,
    required this.bodyKey,
    required this.accentColor,
    required this.badgeColor,
  });

  final String avatarAsset;
  final String teacherKey;
  final String classKey;
  final String timeKey;
  final String studentKey;
  final String bodyKey;
  final Color accentColor;
  final Color badgeColor;
}

class _HomeTeacherMessageCard extends StatelessWidget {
  const _HomeTeacherMessageCard({required this.data});

  final _HomeTeacherMessageData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE1E8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002B6A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      data.avatarAsset,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: data.badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.school_outlined,
                        size: 11,
                        color: data.accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.getText(data.teacherKey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF001741),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.getText(data.classKey),
                      style: const TextStyle(
                        color: Color(0xFF515F6F),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.getText(data.timeKey),
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFB9C0CE),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: data.accentColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    context.getText(data.studentKey),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.getText(data.bodyKey),
                  style: const TextStyle(
                    color: Color(0xFF30333A),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentClassroomTab extends StatefulWidget {
  const _StudentClassroomTab({
    required this.bottomPadding,
    required this.scale,
    required this.user,
    required this.activeProfile,
  });

  final double bottomPadding;
  final double scale;
  final LoginUser? user;
  final StudentProfile? activeProfile;

  @override
  State<_StudentClassroomTab> createState() => _StudentClassroomTabState();
}

class _StudentClassroomTabState extends State<_StudentClassroomTab> {
  final ClassroomService _classroomService = ClassroomApi();
  List<ClassroomModel> _classrooms = const <ClassroomModel>[];
  bool _isLoading = false;
  bool _isSearchContentLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  @override
  void didUpdateWidget(covariant _StudentClassroomTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldProfileId = ActiveProfileSession.profileStableId(
      oldWidget.activeProfile,
    );
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (oldProfileId != profileId) {
      _classrooms = const <ClassroomModel>[];
      _isSearchContentLoading = true;
      _error = null;
      _loadClassrooms();
    }
  }

  Future<void> _loadClassrooms() async {
    if (_isLoading) {
      return;
    }
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0) {
      setState(() {
        _error = context.readText(AppKeys.studentMissingProfileId);
        _classrooms = const <ClassroomModel>[];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final classrooms = await _classroomService.listMyJoinedClassrooms(
        profileId: profileId,
      );
      if (!mounted ||
          ActiveProfileSession.profileStableId(widget.activeProfile) !=
              profileId) {
        return;
      }
      setState(() => _classrooms = classrooms);
    } catch (_) {
      if (!mounted ||
          ActiveProfileSession.profileStableId(widget.activeProfile) !=
              profileId) {
        return;
      }
      setState(() {
        _error = context.readText(AppKeys.studentClassroomLoadFailed);
        _classrooms = const <ClassroomModel>[];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      } else {
        _isLoading = false;
      }
    }
  }

  Future<void> _openClassDetail(ClassroomModel classroom) async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final classroomId = classroom.stableId;
    if (profileId == null || profileId <= 0 || classroomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.readText(AppKeys.teacherClassOpenFailed)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.selectionClick();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => StudentClassDetailScreen(
          classroomId: classroomId,
          profileId: profileId,
          initialClassroom: classroom,
          classroomService: _classroomService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final canLoadContent = profileId != null && profileId > 0;
    final isInitialLoading =
        canLoadContent && (_isLoading || _isSearchContentLoading);
    final scale = widget.scale;
    final topInset = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          _StudentClassroomHeader(scale: scale, topInset: topInset),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Visibility(
                    visible: !isInitialLoading,
                    maintainState: true,
                    child: RefreshIndicator(
                      onRefresh: _loadClassrooms,
                      color: _teal,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          20 * scale,
                          20 * scale,
                          20 * scale,
                          widget.bottomPadding,
                        ),
                        children: [
                          if (_error != null && _classrooms.isEmpty)
                            _StudentInlineErrorPanel(
                              message: _error!,
                              onRetry: _loadClassrooms,
                            )
                          else if (_classrooms.isEmpty)
                            const _StudentFigmaStateCard(
                              titleKey: AppKeys.studentNoClassroomsTitle,
                              messageKey: AppKeys.studentNoClassroomsMessage,
                            )
                          else
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final cardWidth =
                                    (constraints.maxWidth - 10 * scale) / 2;
                                return Wrap(
                                  spacing: 10 * scale,
                                  runSpacing: 12 * scale,
                                  children: [
                                    for (final classroom in _classrooms)
                                      SizedBox(
                                        width: cardWidth,
                                        child: _StudentClassroomTabCard(
                                          classroom: classroom,
                                          onTap: () =>
                                              _openClassDetail(classroom),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          SizedBox(height: 30 * scale),
                          const _StudentJoinAnotherClassroomTitle(),
                          SizedBox(height: 14 * scale),
                          if (canLoadContent)
                            StudentClassSearchContent(
                              profileId: profileId,
                              userId: widget.user?.id,
                              classroomService: _classroomService,
                              onJoinRequested: _loadClassrooms,
                              onInitialLoadingChanged: (isLoading) {
                                if (mounted &&
                                    _isSearchContentLoading != isLoading) {
                                  setState(
                                    () => _isSearchContentLoading = isLoading,
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isInitialLoading)
                  const Positioned.fill(
                    child: _StudentClassroomLoadingRegion(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentClassroomHeader extends StatelessWidget {
  const _StudentClassroomHeader({
    required this.scale,
    required this.topInset,
  });

  final double scale;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: topInset + 60 * scale,
      padding: EdgeInsets.only(top: topInset),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFF2F2F2),
            width: 4 * scale,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        context.getText(AppKeys.studentClassroom),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.andika(
          color: const Color(0xFF339395),
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _StudentClassroomLoadingRegion extends StatelessWidget {
  const _StudentClassroomLoadingRegion();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: _teal),
            const SizedBox(height: 14),
            Text(
              context.getText(AppKeys.loading),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF30333A),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentClassroomTabCard extends StatelessWidget {
  const _StudentClassroomTabCard({
    required this.classroom,
    required this.onTap,
  });

  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = classroom.name?.trim().isNotEmpty == true
        ? classroom.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final teacher = classroom.teacherName?.trim().isNotEmpty == true
        ? classroom.teacherName!.trim()
        : context.getText(AppKeys.teacherFallback);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 22, 12, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD4D8E3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF002B6A).withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF002B6A),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 14),
              _StudentClassroomMetaRow(
                icon: Icons.person_rounded,
                label: teacher,
              ),
              const SizedBox(height: 7),
              _StudentClassroomMetaRow(
                icon: Icons.groups_rounded,
                label: context.formatText(
                  AppKeys.teacherStudentCount,
                  {'count': classroom.displayStudentCount},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentClassroomMetaRow extends StatelessWidget {
  const _StudentClassroomMetaRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF747781)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF747781),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentJoinAnotherClassroomTitle extends StatelessWidget {
  const _StudentJoinAnotherClassroomTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF1EBFA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Color(0xFF6647E8),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.getText(AppKeys.studentJoinAnotherClassroom),
              style: const TextStyle(
                color: Color(0xFF002B6A),
                fontSize: 17,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentInvitationListScreen extends StatefulWidget {
  const _StudentInvitationListScreen({
    required this.profileId,
    required this.classroomService,
    required this.initialInvitations,
  });

  final int profileId;
  final ClassroomService classroomService;
  final List<ClassroomInvitation> initialInvitations;

  @override
  State<_StudentInvitationListScreen> createState() =>
      _StudentInvitationListScreenState();
}

class _StudentInvitationListScreenState
    extends State<_StudentInvitationListScreen> {
  List<ClassroomInvitation> _invitations = const <ClassroomInvitation>[];
  final Set<int> _processingClassroomIds = <int>{};
  bool _isLoading = false;
  bool _acceptedInvitation = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _invitations = widget.initialInvitations;
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final invitations = await widget.classroomService
          .listMyPendingInvitations(profileId: widget.profileId);
      if (!mounted) {
        return;
      }
      setState(() => _invitations = invitations);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = context.readText(AppKeys.studentInvitationLoadFailed);
        _invitations = const <ClassroomInvitation>[];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      } else {
        _isLoading = false;
      }
    }
  }

  Future<void> _handleInvitation(
    ClassroomInvitation invitation, {
    required bool accept,
  }) async {
    final classroomId = invitation.stableClassroomId;
    if (classroomId == null) {
      return;
    }

    final inviterProfileId = invitation.inviterProfileId ?? widget.profileId;
    setState(() => _processingClassroomIds.add(classroomId));
    try {
      if (accept) {
        await widget.classroomService.acceptInvitation(
          inviteeProfileId: widget.profileId,
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
        );
        _acceptedInvitation = true;
      } else {
        await widget.classroomService.rejectInvitation(
          inviteeProfileId: widget.profileId,
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
        );
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.readText(
                accept
                    ? AppKeys.studentInvitationAcceptSuccess
                    : AppKeys.studentInvitationRejectSuccess,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      await _loadInvitations();
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _processingClassroomIds.remove(classroomId));
      }
    }
  }

  void _close() {
    Navigator.of(context).pop(_acceptedInvitation);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _close();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(context.getText(AppKeys.studentClassInvitations)),
        ),
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: _loadInvitations,
            color: _teal,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                if (_isLoading && _invitations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child:
                        Center(child: CircularProgressIndicator(color: _teal)),
                  )
                else if (_error != null && _invitations.isEmpty)
                  _StudentInlineErrorPanel(
                    message: _error!,
                    onRetry: _loadInvitations,
                  )
                else if (_invitations.isEmpty)
                  const _StudentFigmaStateCard(
                    titleKey: AppKeys.studentNoInvitationsTitle,
                    messageKey: AppKeys.studentNoInvitationsMessage,
                  )
                else
                  for (var index = 0; index < _invitations.length; index++) ...[
                    _StudentInvitationCard(
                      invitation: _invitations[index],
                      isProcessing: _processingClassroomIds.contains(
                        _invitations[index].stableClassroomId,
                      ),
                      onAccept: () => _handleInvitation(
                        _invitations[index],
                        accept: true,
                      ),
                      onReject: () => _handleInvitation(
                        _invitations[index],
                        accept: false,
                      ),
                    ),
                    if (index != _invitations.length - 1)
                      const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _StudentHomeTabs extends StatelessWidget {
  const _StudentHomeTabs({
    required this.activePanel,
    required this.scale,
    required this.onChanged,
  });

  final _StudentHomePanel activePanel;
  final double scale;
  final ValueChanged<_StudentHomePanel> onChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = <(_StudentHomePanel, String)>[
      (_StudentHomePanel.homework, context.getText(AppKeys.studentHomework)),
      (_StudentHomePanel.classroom, context.getText(AppKeys.studentClassroom)),
      (_StudentHomePanel.achievement, context.getText(AppKeys.yourAchievement)),
    ];
    final activeIndex = tabs.indexWhere((tab) => tab.$1 == activePanel);

    return Container(
      padding: EdgeInsets.all(5 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.14),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;

          return SizedBox(
            height: 42 * scale,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  left: tabWidth * activeIndex,
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _teal,
                      borderRadius: BorderRadius.circular(20 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: _teal.withValues(alpha: 0.18),
                          blurRadius: 12 * scale,
                          offset: Offset(0, 6 * scale),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final tab in tabs)
                      Expanded(
                        child: _StudentHomeTabButton(
                          label: tab.$2,
                          selected: tab.$1 == activePanel,
                          scale: scale,
                          onTap: () => onChanged(tab.$1),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StudentHomeTabButton extends StatelessWidget {
  const _StudentHomeTabButton({
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20 * scale),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20 * scale),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: 42 * scale,
            padding: EdgeInsets.symmetric(horizontal: 8 * scale),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: selected ? Colors.white : _muted,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeworkPanel extends StatelessWidget {
  const _HomeworkPanel({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _StudentEmptyPanel(
      scale: scale,
      icon: Icons.assignment_rounded,
      title: context.getText(AppKeys.studentNoHomeworkTitle),
      message: context.getText(AppKeys.studentNoHomeworkMessage),
    );
  }
}

class _StudentClassroomPanel extends StatelessWidget {
  const _StudentClassroomPanel({
    super.key,
    required this.scale,
    required this.classrooms,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onJoinClassroom,
  });

  final double scale;
  final List<ClassroomModel> classrooms;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onJoinClassroom;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _JoinClassroomButton(
            scale: scale,
            onTap: onJoinClassroom,
          ),
        ),
        SizedBox(height: 14 * scale),
        if (isLoading && classrooms.isEmpty)
          _StudentLoadingPanel(scale: scale)
        else if (error != null && classrooms.isEmpty)
          _StudentErrorPanel(
            scale: scale,
            message: error!,
            onRetry: onRetry,
          )
        else if (classrooms.isEmpty)
          _StudentEmptyPanel(
            scale: scale,
            icon: Icons.groups_rounded,
            title: context.getText(AppKeys.studentNoClassroomsTitle),
            message: context.getText(AppKeys.studentNoClassroomsMessage),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < classrooms.length; index++) ...[
                _StudentClassroomCard(
                  scale: scale,
                  classroom: classrooms[index],
                ),
                if (index != classrooms.length - 1)
                  SizedBox(height: 12 * scale),
              ],
            ],
          ),
      ],
    );
  }
}

class _JoinClassroomButton extends StatelessWidget {
  const _JoinClassroomButton({
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFF7B54),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 11 * scale,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 18 * scale),
              SizedBox(width: 6 * scale),
              Text(
                context.getText(AppKeys.studentJoinNewClassroom),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentClassroomCard extends StatelessWidget {
  const _StudentClassroomCard({
    required this.scale,
    required this.classroom,
  });

  final double scale;
  final ClassroomModel classroom;

  @override
  Widget build(BuildContext context) {
    final title = classroom.name?.trim().isNotEmpty == true
        ? classroom.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final description = classroom.description?.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(26 * scale),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56 * scale,
            height: 56 * scale,
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(22 * scale),
            ),
            child: Icon(
              Icons.school_rounded,
              color: _teal,
              size: 27 * scale,
            ),
          ),
          SizedBox(width: 15 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _deepInk,
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  description != null && description.isNotEmpty
                      ? description
                      : context.formatText(
                          AppKeys.teacherStudentCount,
                          {'count': classroom.displayStudentCount},
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.grayText,
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * scale),
          Icon(
            Icons.chevron_right_rounded,
            color: _teal,
            size: 26 * scale,
          ),
        ],
      ),
    );
  }
}

class _AchievementPanel extends StatelessWidget {
  const _AchievementPanel({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('achievement_panel_content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AchievementsHeader(scale: scale),
        SizedBox(height: 20 * scale),
        _AchievementCard(scale: scale),
      ],
    );
  }
}

class _StudentLoadingPanel extends StatelessWidget {
  const _StudentLoadingPanel({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 132 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(28 * scale),
      ),
      child: SizedBox(
        width: 26 * scale,
        height: 26 * scale,
        child: const CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }
}

class _StudentErrorPanel extends StatelessWidget {
  const _StudentErrorPanel({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  final double scale;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _StudentMessagePanel(
      scale: scale,
      icon: Icons.wifi_off_rounded,
      title: message,
      message: context.getText(AppKeys.retry),
      actionLabel: context.getText(AppKeys.retryUpper),
      onAction: onRetry,
    );
  }
}

class _StudentEmptyPanel extends StatelessWidget {
  const _StudentEmptyPanel({
    required this.scale,
    required this.icon,
    required this.title,
    required this.message,
  });

  final double scale;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _StudentMessagePanel(
      scale: scale,
      icon: icon,
      title: title,
      message: message,
    );
  }
}

class _StudentMessagePanel extends StatelessWidget {
  const _StudentMessagePanel({
    required this.scale,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final double scale;
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(30 * scale),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58 * scale,
            height: 58 * scale,
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24 * scale),
            ),
            child: Icon(icon, color: _teal, size: 28 * scale),
          ),
          SizedBox(height: 14 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _deepInk,
              fontSize: 16 * scale,
              fontWeight: FontWeight.w900,
              height: 1.15,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.grayText,
              fontSize: 13 * scale,
              fontWeight: FontWeight.w700,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 16 * scale),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _AchievementsHeader extends StatelessWidget {
  const _AchievementsHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.getText(AppKeys.yourAchievement),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _deepInk,
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 10 * scale),
              Container(
                width: 48 * scale,
                height: 4 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFA03A0F).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 3 * scale),
          child: Text(
            context.getText(AppKeys.viewAllUpper),
            style: TextStyle(
              color: _teal,
              fontSize: 11 * scale,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104 * scale,
      padding: EdgeInsets.all(21 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(32 * scale),
        border:
            Border.all(color: const Color(0xFFA2B1A3).withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2 * scale,
            offset: Offset(0, 1 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64 * scale,
            height: 64 * scale,
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(28 * scale),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: _teal,
              size: 28 * scale,
            ),
          ),
          SizedBox(width: 20 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.getText(AppKeys.progressAchievementTitle),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _deepInk,
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  context.getText(AppKeys.todayCompletedExercises),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.grayText,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * scale),
          Container(
            width: 36 * scale,
            height: 36 * scale,
            decoration: const BoxDecoration(
              color: Color(0xFFDBEDDC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: _teal,
              size: 24 * scale,
            ),
          ),
        ],
      ),
    );
  }
}

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
            Icons.explore_outlined,
            context.getText(AppKeys.navReview),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(items.length, (index) {
                return _AnimatedNavItem(
                  data: items[index],
                  active: activeIndex == index,
                  teacherStyle: activeRole == ProfileRole.teacher,
                  scale: scale,
                  onTap: () => onTabSelected(index),
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
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
      tween: Tween<double>(end: active ? 1 : 0),
      builder: (context, value, child) {
        final color = Color.lerp(inactiveColor, Colors.white, value)!;
        return Semantics(
          selected: active,
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(48 * scale),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: active ? 72 * scale : 58 * scale,
                height: active ? 64 * scale : 56 * scale,
                padding: EdgeInsets.symmetric(
                  horizontal: active ? 10 * scale : 8 * scale,
                  vertical: active ? 10 * scale : 8 * scale,
                ),
                decoration: BoxDecoration(
                  color: Color.lerp(Colors.transparent, activeColor, value),
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
                    Transform.scale(
                      scale: 1 + (0.10 * value),
                      child: data.user != null
                          ? _UserAvatarWidget(
                              user: data.user!,
                              size: (active ? 18 : 18) * scale,
                              color: color,
                            )
                          : data.assetPath != null
                              ? SvgPicture.asset(
                                  data.assetPath!,
                                  width: 18 * scale,
                                  height: 18 * scale,
                                  colorFilter: ColorFilter.mode(
                                    color,
                                    BlendMode.srcIn,
                                  ),
                                )
                              : Icon(
                                  data.icon,
                                  color: color,
                                  size: (active ? 18 : 18) * scale,
                                ),
                    ),
                    SizedBox(height: 4 * scale),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        data.label,
                        maxLines: 1,
                        style: TextStyle(
                          color: color,
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
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

class _HeroMathGlyph extends StatelessWidget {
  const _HeroMathGlyph({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text(
      'x²',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.10),
        fontSize: 64 * scale,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: 0,
      ),
    );
  }
}

class _HeroTriangleGhost extends StatelessWidget {
  const _HeroTriangleGhost({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58 * scale,
      height: 58 * scale,
      child: CustomPaint(
        painter: _TriangleOutlinePainter(
          color: Colors.white.withValues(alpha: 0.12),
          strokeWidth: 6 * scale,
        ),
      ),
    );
  }
}

class _TriangleOutlinePainter extends CustomPainter {
  const _TriangleOutlinePainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width / 2, size.height * 0.14)
      ..lineTo(size.width * 0.9, size.height * 0.84)
      ..lineTo(size.width * 0.1, size.height * 0.84)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TriangleOutlinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
