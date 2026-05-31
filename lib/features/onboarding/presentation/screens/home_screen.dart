import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';
import '../../../../core/network/grade_models.dart';
import '../../../../core/network/profile_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/active_profile_session.dart';
import '../../data/otp_auth_api.dart';
import '../../data/grade_api.dart';
import '../../data/quiz_api.dart';
import '../tabs/history_tab.dart';
import '../tabs/review_tab.dart';
import '../tabs/setting_tab.dart';
import '../widgets/profile_avatar_image.dart';
import 'grade_selection_screen.dart';
import 'teacher_classroom_screens.dart';

const _teal = Color(0xFF006762);
const _muted = Color(0xFF515F54);
const _deepInk = Color(0xFF253228);
const _mintBackground = Color(0xFFEEF9FB);

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.activeRole,
    required this.profileLoadError,
    required this.onRefreshProfiles,
    required this.onBack,
    required this.onLogout,
  });

  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final ProfileRole activeRole;
  final String? profileLoadError;
  final Future<void> Function() onRefreshProfiles;
  final VoidCallback onBack;
  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GradeService _gradeService = GradeApi();
  int _activeTab = 0;
  int _previousActiveTab = 0;
  int _openAddProfileRequestId = 0;
  bool _returnToReviewAfterProfileSave = false;
  String? _prefetchedGradeUserId;
  bool _isPrefetchingGrades = false;
  List<GradeModel> _prefetchedGrades = const <GradeModel>[];

  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

  @override
  void initState() {
    super.initState();
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
        widget.activeRole == ProfileRole.teacher &&
        _activeTab > 2) {
      _previousActiveTab = _activeTab;
      _activeTab = 0;
    }
  }

  Future<void> _prefetchGrades() async {
    final userId = widget.user?.id.trim();
    if (userId == null ||
        userId.isEmpty ||
        _isPrefetchingGrades ||
        (_prefetchedGradeUserId == userId && _prefetchedGrades.isNotEmpty)) {
      return;
    }

    _isPrefetchingGrades = true;
    _prefetchedGradeUserId = userId;

    try {
      final grades = await _gradeService.listGrades(userId: userId);
      if (!mounted || widget.user?.id.trim() != userId) {
        return;
      }

      setState(() => _prefetchedGrades = grades);
    } catch (_) {
      if (!mounted || widget.user?.id.trim() != userId) {
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
        final studentName = _displayProfileName(widget.activeProfile);

        double s(double value) => value * scale;
        final navHeight = s(88) + bottomInset;
        final headerHeight = s(98) + topInset;
        final showHeader =
            widget.activeRole != ProfileRole.teacher && _activeTab == 0;

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
                      key: ValueKey(_activeTab),
                      activeTab: _activeTab,
                      user: widget.user,
                      profiles: widget.profiles,
                      activeProfile: widget.activeProfile,
                      activeRole: widget.activeRole,
                      profileLoadError: widget.profileLoadError,
                      onRefreshProfiles: widget.onRefreshProfiles,
                      initialGrades: _prefetchedGrades,
                      gradeService: _gradeService,
                      onLogout: widget.onLogout,
                      onAddProfileFromReview: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _previousActiveTab = _activeTab;
                          _activeTab = 3;
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
                          _activeTab = 1;
                          _returnToReviewAfterProfileSave = false;
                        });
                      },
                      openAddProfileRequestId: _openAddProfileRequestId,
                      bottomPadding: navHeight + s(14),
                      headerHeight: showHeader ? headerHeight : 0,
                      scale: scale,
                    ),
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
                      setState(() {
                        _previousActiveTab = _activeTab;
                        _activeTab = index;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _displayProfileName(StudentProfile? profile) {
    final name = profile?.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return 'Student';
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
    required this.initialGrades,
    required this.gradeService,
    required this.onLogout,
    required this.onAddProfileFromReview,
    required this.onProfileSaved,
    required this.openAddProfileRequestId,
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
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final VoidCallback onLogout;
  final VoidCallback onAddProfileFromReview;
  final VoidCallback onProfileSaved;
  final int openAddProfileRequestId;
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
      );
    }

    if (activeTab == 1) {
      return TeacherReportTab(
        bottomPadding: bottomPadding,
        scale: scale,
      );
    }

    if (activeTab == 2) {
      return SettingTab(
        user: user,
        profiles: profiles,
        activeProfile: activeProfile,
        profileLoadError: profileLoadError,
        onLogout: onLogout,
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
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: horizontalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TestHeroCard(
              height: 430 * scale,
              scale: scale,
              user: user,
              initialGrades: initialGrades,
              gradeService: gradeService,
            ),
            SizedBox(height: 28 * scale),
            _AchievementsHeader(scale: scale),
            SizedBox(height: 20 * scale),
            _AchievementCard(scale: scale),
          ],
        ),
      );
    }

    if (activeTab == 3) {
      return SettingTab(
        user: user,
        profiles: profiles,
        activeProfile: activeProfile,
        profileLoadError: profileLoadError,
        onLogout: onLogout,
        onProfileSaved: onProfileSaved,
        openAddProfileRequestId: openAddProfileRequestId,
        bottomPadding: bottomPadding,
        scale: scale,
      );
    }

    if (activeTab == 1) {
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

    if (activeTab == 2) {
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
        color: _mintBackground,
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
  });

  final double height;
  final double topInset;
  final double horizontalPadding;
  final String name;
  final StudentProfile? profile;

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
            color: _mintBackground.withValues(alpha: 0.92),
          ),
          child: Row(
            children: [
              _StudentAvatar(
                size: contentHeight * 0.45,
                avatarKey: profile?.avatarKey,
                avatarUrl: profile?.avatarUrl,
              ),
              SizedBox(width: contentHeight * 0.14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.getText(AppKeys.student),
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
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _teal,
                        fontSize: contentHeight * 0.18,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
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
          child: Icon(
            Icons.notifications_none_rounded,
            color: _teal,
            size: size * 0.50,
          ),
        ),
      ),
    );
  }
}

class _TestHeroCard extends StatelessWidget {
  const _TestHeroCard({
    required this.height,
    required this.scale,
    required this.user,
    required this.initialGrades,
    required this.gradeService,
  });

  final double height;
  final double scale;
  final LoginUser? user;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;

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
    final items = activeRole == ProfileRole.teacher
        ? [
            _NavItemData(
              Icons.home_filled,
              context.getText(AppKeys.navHome),
              null,
            ),
            _NavItemData(
              Icons.bar_chart_rounded,
              context.getText(AppKeys.navReport),
              null,
            ),
            _NavItemData(null, context.getText(AppKeys.navSettings), user),
          ]
        : [
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
          ];

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
  const _NavItemData(this.icon, this.label, this.user);

  final IconData? icon;
  final String label;
  final LoginUser? user;
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
