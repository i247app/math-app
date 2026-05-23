import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/quiz_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/otp_auth_api.dart';
import '../../data/quiz_api.dart';
import 'grade_selection_screen.dart';

const _teal = Color(0xFF006762);
const _muted = Color(0xFF515F54);
const _deepInk = Color(0xFF253228);
const _orange = Color(0xFFDE5E31);
const _mintBackground = Color(0xFFEBFAEC);
const _useFakeQuizApi = bool.fromEnvironment('USE_FAKE_QUIZ_API');

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.onBack,
    required this.onLogout,
  });

  final LoginUser? user;
  final VoidCallback onBack;
  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTab = 0;

  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, 430.0);
        final height = constraints.maxHeight;
        final viewportHeight = MediaQuery.sizeOf(context).height;
        final scale =
            math.min(width / _designWidth, viewportHeight / _designHeight);
        final studentName = _displayName(widget.user);

        double s(double value) => value * scale;
        final navHeight = s(88);
        final showHeader = _activeTab == 0;

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
                      final offset = Tween<Offset>(
                        begin: const Offset(0.035, 0),
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
                      onLogout: widget.onLogout,
                      bottomPadding: navHeight + s(24),
                      headerHeight: showHeader ? s(98) : 0,
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
                      height: s(98),
                      horizontalPadding: s(24),
                      name: studentName,
                      user: widget.user,
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _BottomNavigation(
                    height: navHeight,
                    scale: scale,
                    activeIndex: _activeTab,
                    onTabSelected: (index) {
                      if (index == _activeTab) {
                        HapticFeedback.selectionClick();
                        return;
                      }

                      HapticFeedback.lightImpact();
                      setState(() => _activeTab = index);
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

  String _displayName(LoginUser? user) {
    final name = user?.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return 'Minh Quân';
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    super.key,
    required this.activeTab,
    required this.user,
    required this.onLogout,
    required this.bottomPadding,
    required this.headerHeight,
    required this.scale,
  });

  final int activeTab;
  final LoginUser? user;
  final VoidCallback onLogout;
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

    if (activeTab == 0) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: horizontalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TestHeroCard(height: 430 * scale, scale: scale),
            SizedBox(height: 28 * scale),
            _AchievementsHeader(scale: scale),
            SizedBox(height: 20 * scale),
            _AchievementCard(scale: scale),
          ],
        ),
      );
    }

    if (activeTab == 3) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: horizontalPadding,
        child: _AccountTab(
          user: user,
          onLogout: onLogout,
          minHeight: 487 * scale,
          scale: scale,
        ),
      );
    }

    if (activeTab == 2) {
      return _HistoryTab(
        user: user,
        bottomPadding: bottomPadding,
        scale: scale,
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: horizontalPadding,
      child: _SoonTab(
        icon:
            activeTab == 1 ? Icons.auto_stories_rounded : Icons.history_rounded,
        title: activeTab == 1 ? 'Ôn tập' : 'Lịch sử',
        subtitle: activeTab == 1
            ? 'Các bài luyện tập sẽ xuất hiện tại đây.'
            : 'Lịch sử học tập sẽ được cập nhật sau mỗi buổi học.',
        minHeight: 487 * scale,
        scale: scale,
      ),
    );
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
    required this.horizontalPadding,
    required this.name,
    required this.user,
  });

  final double height;
  final double horizontalPadding;
  final String name;
  final LoginUser? user;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: height,
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            height * 0.20,
            horizontalPadding,
            height * 0.21,
          ),
          decoration: BoxDecoration(
            color: _mintBackground.withValues(alpha: 0.92),
          ),
          child: Row(
            children: [
              _StudentAvatar(
                size: height * 0.45,
                avatarUrl: user?.avatarUrl,
              ),
              SizedBox(width: height * 0.14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HỌC SINH',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _muted.withValues(alpha: 0.6),
                        fontFamily: 'Nunito',
                        fontSize: height * 0.10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: height * 0.06),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _teal,
                        fontFamily: 'Nunito',
                        fontSize: height * 0.18,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              _NotificationButton(size: height * 0.45),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({required this.size, this.avatarUrl});

  final double size;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.peach,
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
          clipBehavior: Clip.antiAlias,
          child: url == null || url.isEmpty
              ? Icon(
                  Icons.person_rounded,
                  color: const Color(0xFF2A7D75),
                  size: size * 0.66,
                )
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Icon(
                      Icons.person_rounded,
                      color: const Color(0xFF2A7D75),
                      size: size * 0.66,
                    );
                  },
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
  const _TestHeroCard({required this.height, required this.scale});

  final double height;
  final double scale;

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
                  'KIỂM TRA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontSize: 34 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 15 * scale),
                Text(
                  'Cùng AI kiểm tra khả năng toán học\nvượt trội riêng bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontFamily: 'Nunito',
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
            child: _HeroButton(
              scale: scale,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const GradeSelectionScreen(),
                  ),
                );
              },
            ),
          ),
        ],
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
            bottom: 12 * scale,
            child: Container(
              width: 176 * scale,
              height: 29 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF253228).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF253228).withValues(alpha: 0.12),
                    blurRadius: 18 * scale,
                    spreadRadius: 2 * scale,
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
            fontFamily: 'Nunito',
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
  const _HeroButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

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
                    color: const Color(0xFF621C00),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA03A0F).withValues(alpha: 0.34),
                        blurRadius: 18 * widget.scale,
                        offset: Offset(0, 12 * widget.scale),
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
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF9F7D), Color(0xFFA03A0F)],
                ),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bắt đầu ngay',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontSize: 17 * widget.scale,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(width: 10 * widget.scale),
                  Icon(
                    Icons.rocket_launch_outlined,
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
                'Thành tích của bạn',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _deepInk,
                  fontFamily: 'Nunito',
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
            'XEM TẤT CẢ',
            style: TextStyle(
              color: _teal,
              fontFamily: 'Nunito',
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
                  'Tiến độ vượt bậc',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _deepInk,
                    fontFamily: 'Nunito',
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  'Đã hoàn thành 12 bài tập hôm nay',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.grayText,
                    fontFamily: 'Nunito',
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
    required this.scale,
    required this.activeIndex,
    required this.onTabSelected,
  });

  final double height;
  final double scale;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItemData(Icons.home_filled, 'HOME'),
      _NavItemData(Icons.explore_outlined, 'ÔN TẬP'),
      _NavItemData(Icons.map_outlined, 'LỊCH SỬ'),
      _NavItemData(Icons.person_outline_rounded, 'TÀI KHOẢN'),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(48 * scale)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: height,
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            12 * scale,
            20 * scale,
            16 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(48 * scale)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 32 * scale,
                offset: Offset(0, -8 * scale),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              return Expanded(
                child: _AnimatedNavItem(
                  data: items[index],
                  active: activeIndex == index,
                  scale: scale,
                  onTap: () => onTabSelected(index),
                ),
              );
            }),
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
    required this.scale,
    required this.onTap,
  });

  final _NavItemData data;
  final bool active;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = const Color(0xFF515F54).withValues(alpha: 0.68);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
      tween: Tween<double>(end: active ? 1 : 0),
      builder: (context, value, child) {
        final color = Color.lerp(inactiveColor, Colors.white, value)!;
        final lift = -5 * scale * value;

        return Semantics(
          selected: active,
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(48 * scale),
              child: Transform.translate(
                offset: Offset(0, lift),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  height: 60 * scale,
                  margin: EdgeInsets.symmetric(horizontal: 2 * scale),
                  padding: EdgeInsets.symmetric(
                    horizontal: active ? 14 * scale : 8 * scale,
                    vertical: active ? 8 * scale : 7 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: Color.lerp(Colors.transparent, _teal, value),
                    borderRadius: BorderRadius.circular(48 * scale),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: _teal.withValues(alpha: 0.26),
                              blurRadius: 14 * scale,
                              offset: Offset(0, 10 * scale),
                            ),
                            BoxShadow(
                              color: _teal.withValues(alpha: 0.18),
                              blurRadius: 6 * scale,
                              offset: Offset(0, 3 * scale),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: 1 + (0.12 * value),
                        child: Icon(
                          data.icon,
                          color: color,
                          size: (active ? 20 : 19) * scale,
                        ),
                      ),
                      SizedBox(height: 5 * scale),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          data.label,
                          maxLines: 1,
                          style: TextStyle(
                            color: color,
                            fontFamily: 'Nunito',
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            letterSpacing: active ? 0.2 : 0,
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

class _NavItemData {
  const _NavItemData(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _AccountTab extends StatelessWidget {
  const _AccountTab({
    required this.user,
    required this.onLogout,
    required this.minHeight,
    required this.scale,
  });

  final LoginUser? user;
  final VoidCallback onLogout;
  final double minHeight;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final userName = user?.name?.trim() ?? 'Minh Quân';
    final userEmail = user?.email?.trim() ?? '';
    final userPhone = user?.phone?.trim() ?? '';

    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.all(28 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(40 * scale),
        border:
            Border.all(color: const Color(0xFFA2B1A3).withValues(alpha: 0.14)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StudentAvatar(size: 84 * scale, avatarUrl: user?.avatarUrl),
          SizedBox(height: 20 * scale),
          Text(
            userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _teal,
              fontFamily: 'Nunito',
              fontSize: 22 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          if (userPhone.isNotEmpty) ...[
            SizedBox(height: 8 * scale),
            Text(
              userPhone,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _muted,
                fontFamily: 'Nunito',
                fontSize: 14 * scale,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
          if (userEmail.isNotEmpty) ...[
            SizedBox(height: 4 * scale),
            Text(
              userEmail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _muted,
                fontFamily: 'Nunito',
                fontSize: 14 * scale,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
          SizedBox(height: 30 * scale),
          SizedBox(
            height: 46 * scale,
            child: ElevatedButton(
              onPressed: onLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 30 * scale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18 * scale),
                ),
              ),
              child: Text(
                'ĐĂNG XUẤT',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTab extends StatefulWidget {
  const _HistoryTab({
    required this.user,
    required this.bottomPadding,
    required this.scale,
  });

  final LoginUser? user;
  final double bottomPadding;
  final double scale;

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  late final QuizService _quizService =
      _useFakeQuizApi ? const FakeQuizApi() : QuizApi();
  final TextEditingController _searchController = TextEditingController();

  _HistoryFilter _selectedFilter = _HistoryFilter.all;
  List<GeneratedQuiz> _quizzes = const <GeneratedQuiz>[];
  bool _isLoading = true;
  String? _errorMessage;
  int _loadRequestId = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshSearch);
    _loadHistory();
  }

  @override
  void didUpdateWidget(covariant _HistoryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.id != widget.user?.id) {
      _loadHistory();
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshSearch)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final requestId = ++_loadRequestId;
    final userId = widget.user?.id.trim();
    if (userId == null || userId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Chưa có thông tin tài khoản để tải lịch sử.';
        _quizzes = const <GeneratedQuiz>[];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final quizzes = await _quizService.listQuizzes(userId: userId);
      if (!mounted || requestId != _loadRequestId) {
        return;
      }
      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
      });
    } on QuizException catch (error) {
      if (!mounted || requestId != _loadRequestId) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _loadRequestId) {
        return;
      }
      setState(() {
        _errorMessage = 'Tải lịch sử thất bại.';
        _isLoading = false;
      });
    }
  }

  void _refreshSearch() {
    setState(() {});
  }

  void _selectFilter(_HistoryFilter filter) {
    HapticFeedback.selectionClick();
    setState(() => _selectedFilter = filter);
  }

  List<GeneratedQuiz> get _filteredQuizzes {
    final query = _searchController.text.trim().toLowerCase();
    return _quizzes.where((quiz) {
      final matchesFilter = _selectedFilter == _HistoryFilter.all ||
          _quizFilterOf(quiz) == _selectedFilter;
      if (!matchesFilter) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final searchable = <String>[
        _quizTitle(quiz),
        quiz.type ?? '',
        quiz.quizStatus ?? '',
        quiz.grading?.aiDetectGrade ?? '',
        ...quiz.questions.map((question) => question.questionName),
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final quizzes = _filteredQuizzes;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        24 * scale,
        26 * scale,
        24 * scale,
        widget.bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HistoryTitleRow(scale: scale),
          SizedBox(height: 26 * scale),
          _HistorySearchField(
            controller: _searchController,
            scale: scale,
          ),
          SizedBox(height: 22 * scale),
          _HistoryFilterBar(
            selected: _selectedFilter,
            onSelected: _selectFilter,
            scale: scale,
          ),
          SizedBox(height: 26 * scale),
          _HistorySectionHeader(scale: scale),
          SizedBox(height: 18 * scale),
          if (_isLoading)
            _HistoryLoadingState(scale: scale)
          else if (_errorMessage != null)
            _HistoryMessageState(
              icon: Icons.cloud_off_rounded,
              title: 'Chưa tải được lịch sử',
              subtitle: _errorMessage!,
              actionLabel: 'THỬ LẠI',
              onAction: _loadHistory,
              scale: scale,
            )
          else if (quizzes.isEmpty)
            _HistoryMessageState(
              icon: Icons.history_toggle_off_rounded,
              title: 'Chưa có bài phù hợp',
              subtitle: 'Đổi từ khóa hoặc tab để xem các bài khác.',
              scale: scale,
            )
          else
            for (final quiz in quizzes) ...[
              _HistoryQuizCard(quiz: quiz, scale: scale),
              SizedBox(height: 18 * scale),
            ],
        ],
      ),
    );
  }
}

class _HistoryTitleRow extends StatelessWidget {
  const _HistoryTitleRow({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Lịch sử kiểm tra',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _teal,
              fontFamily: 'Nunito',
              fontSize: 24 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        Icon(
          Icons.more_vert_rounded,
          color: _teal,
          size: 28 * scale,
        ),
      ],
    );
  }
}

class _HistorySearchField extends StatelessWidget {
  const _HistorySearchField({
    required this.controller,
    required this.scale,
  });

  final TextEditingController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56 * scale,
      child: TextField(
        controller: controller,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: _deepInk,
          fontFamily: 'Nunito',
          fontSize: 15 * scale,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bài kiểm tra...',
          hintStyle: TextStyle(
            color: _muted.withValues(alpha: 0.45),
            fontFamily: 'Nunito',
            fontSize: 15 * scale,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _teal,
            size: 28 * scale,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.28),
          contentPadding: EdgeInsets.symmetric(horizontal: 18 * scale),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26 * scale),
            borderSide: BorderSide(
              color: const Color(0xFF9DB8A2).withValues(alpha: 0.42),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26 * scale),
            borderSide: BorderSide(
              color: const Color(0xFF9DB8A2).withValues(alpha: 0.42),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26 * scale),
            borderSide: BorderSide(color: _teal, width: 1.4 * scale),
          ),
        ),
      ),
    );
  }
}

class _HistoryFilterBar extends StatelessWidget {
  const _HistoryFilterBar({
    required this.selected,
    required this.onSelected,
    required this.scale,
  });

  final _HistoryFilter selected;
  final ValueChanged<_HistoryFilter> onSelected;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final filter = _historyFilters[index];
          final isSelected = filter.value == selected;
          return _HistoryFilterChip(
            label: filter.label,
            isSelected: isSelected,
            onTap: () => onSelected(filter.value),
            scale: scale,
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 14 * scale),
        itemCount: _historyFilters.length,
      ),
    );
  }
}

class _HistoryFilterChip extends StatelessWidget {
  const _HistoryFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.scale,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48 * scale,
      child: Material(
        color: isSelected ? _teal : Colors.white,
        elevation: isSelected ? 8 : 2,
        shadowColor: isSelected
            ? _teal.withValues(alpha: 0.24)
            : Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24 * scale),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24 * scale),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 26 * scale),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : _deepInk,
                  fontFamily: 'Nunito',
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w900,
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

class _HistorySectionHeader extends StatelessWidget {
  const _HistorySectionHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Gần đây',
            style: TextStyle(
              color: _deepInk,
              fontFamily: 'Nunito',
              fontSize: 23 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        Icon(
          Icons.tune_rounded,
          color: _muted,
          size: 26 * scale,
        ),
      ],
    );
  }
}

class _HistoryQuizCard extends StatelessWidget {
  const _HistoryQuizCard({
    required this.quiz,
    required this.scale,
  });

  final GeneratedQuiz quiz;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final grading = quiz.grading;
    final correct = grading?.correctNumber;
    final total = grading?.totalQuestions ?? quiz.questions.length;
    final percent = grading?.scorePercentage;
    final hasScore = correct != null && total > 0;
    final scoreColors = _scoreColors(percent);

    return Container(
      constraints: BoxConstraints(minHeight: 144 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: _teal.withValues(alpha: 0.08),
            blurRadius: 22 * scale,
            offset: Offset(0, 10 * scale),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 10 * scale,
            bottom: 10 * scale,
            child: Container(
              width: 4 * scale,
              decoration: BoxDecoration(
                color: _teal,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8 * scale),
                  bottomRight: Radius.circular(8 * scale),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              26 * scale,
              22 * scale,
              18 * scale,
              20 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatHistoryDate(quiz.createDt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _muted.withValues(alpha: 0.58),
                              fontFamily: 'Nunito',
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          Text(
                            _quizTitle(quiz),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _deepInk,
                              fontFamily: 'Nunito',
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    if (hasScore)
                      _HistoryScoreBadge(
                        correct: correct,
                        total: total,
                        colors: scoreColors,
                        scale: scale,
                      )
                    else
                      _HistoryIncompleteBadge(
                        scale: scale,
                      ),
                  ],
                ),
                SizedBox(height: 26 * scale),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: _muted.withValues(alpha: 0.72),
                      size: 20 * scale,
                    ),
                    SizedBox(width: 8 * scale),
                    Expanded(
                      child: Text(
                        '${quiz.questions.length} câu hỏi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _muted,
                          fontFamily: 'Nunito',
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: _teal,
                      size: 32 * scale,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryScoreBadge extends StatelessWidget {
  const _HistoryScoreBadge({
    required this.correct,
    required this.total,
    required this.colors,
    required this.scale,
  });

  final int correct;
  final int total;
  final _ScoreBadgeColors colors;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78 * scale,
      height: 64 * scale,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(32 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                color: colors.foreground,
                fontFamily: 'Nunito',
                letterSpacing: 0,
              ),
              children: [
                TextSpan(
                  text: '$correct',
                  style: TextStyle(
                    fontSize: 27 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: '/$total',
                  style: TextStyle(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'ĐIỂM SỐ',
            style: TextStyle(
              color: colors.foreground,
              fontFamily: 'Nunito',
              fontSize: 9 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryIncompleteBadge extends StatelessWidget {
  const _HistoryIncompleteBadge({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 96 * scale),
      child: Text(
        'Chưa hoàn thành',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: _orange,
          fontFamily: 'Nunito',
          fontSize: 12 * scale,
          fontWeight: FontWeight.w900,
          height: 1.05,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _HistoryLoadingState extends StatelessWidget {
  const _HistoryLoadingState({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168 * scale,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28 * scale),
      ),
      child: Center(
        child: SizedBox(
          width: 34 * scale,
          height: 34 * scale,
          child: const CircularProgressIndicator(
            color: _teal,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}

class _HistoryMessageState extends StatelessWidget {
  const _HistoryMessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.scale,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(26 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28 * scale),
      ),
      child: Column(
        children: [
          Icon(icon, color: _teal, size: 42 * scale),
          SizedBox(height: 14 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _deepInk,
              fontFamily: 'Nunito',
              fontSize: 18 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontFamily: 'Nunito',
              fontSize: 13 * scale,
              fontWeight: FontWeight.w700,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 18 * scale),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: TextStyle(
                  color: _teal,
                  fontFamily: 'Nunito',
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _HistoryFilter { all, review, assessment, practice }

class _HistoryFilterData {
  const _HistoryFilterData(this.value, this.label);

  final _HistoryFilter value;
  final String label;
}

const _historyFilters = <_HistoryFilterData>[
  _HistoryFilterData(_HistoryFilter.all, 'Tất cả'),
  _HistoryFilterData(_HistoryFilter.review, 'Ôn tập'),
  _HistoryFilterData(_HistoryFilter.assessment, 'Kiểm Tra'),
  _HistoryFilterData(_HistoryFilter.practice, 'Luyện Tập'),
];

class _ScoreBadgeColors {
  const _ScoreBadgeColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}

_HistoryFilter _quizFilterOf(GeneratedQuiz quiz) {
  final type = quiz.type?.toUpperCase();
  if (type == 'ASSESSMENT') {
    return _HistoryFilter.assessment;
  }
  if (type == 'PRACTICE') {
    return _HistoryFilter.practice;
  }
  return _HistoryFilter.review;
}

String _quizTitle(GeneratedQuiz quiz) {
  final grade = quiz.grading?.aiDetectGrade?.trim();
  final suffix = grade != null && grade.isNotEmpty ? ' $grade' : '';
  switch (_quizFilterOf(quiz)) {
    case _HistoryFilter.assessment:
      return 'Bài kiểm tra Toán$suffix';
    case _HistoryFilter.practice:
      return 'Bài luyện tập Toán$suffix';
    case _HistoryFilter.review:
      return 'Bài ôn tập Toán$suffix';
    case _HistoryFilter.all:
      return 'Bài học Toán$suffix';
  }
}

_ScoreBadgeColors _scoreColors(int? percent) {
  if (percent == null || percent >= 85) {
    return const _ScoreBadgeColors(
      background: _teal,
      foreground: Colors.white,
    );
  }
  if (percent >= 70) {
    return const _ScoreBadgeColors(
      background: Color(0xFFE4F3F0),
      foreground: _teal,
    );
  }
  return const _ScoreBadgeColors(
    background: Color(0xFFF7E8E3),
    foreground: _orange,
  );
}

String _formatHistoryDate(String? isoDate) {
  if (isoDate == null || isoDate.trim().isEmpty) {
    return 'Không rõ thời gian';
  }

  final parsed = DateTime.tryParse(isoDate)?.toLocal();
  if (parsed == null) {
    return isoDate;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(parsed.year, parsed.month, parsed.day);
  final time = '${_twoDigits(parsed.hour)}:${_twoDigits(parsed.minute)}';
  final difference = today.difference(date).inDays;

  if (difference == 0) {
    return 'Hôm nay, $time';
  }
  if (difference == 1) {
    return 'Hôm qua, $time';
  }

  return '${_twoDigits(parsed.day)}/${_twoDigits(parsed.month)}, $time';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

class _SoonTab extends StatelessWidget {
  const _SoonTab({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.minHeight,
    required this.scale,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double minHeight;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.all(28 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(40 * scale),
        border:
            Border.all(color: const Color(0xFFA2B1A3).withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76 * scale,
            height: 76 * scale,
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(28 * scale),
            ),
            child: Icon(icon, color: _teal, size: 36 * scale),
          ),
          SizedBox(height: 20 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _deepInk,
              fontFamily: 'Nunito',
              fontSize: 22 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontFamily: 'Nunito',
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
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
        fontFamily: 'Nunito',
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
