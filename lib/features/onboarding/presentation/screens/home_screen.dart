import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/otp_auth_api.dart';

const _teal = Color(0xFF008778);
const _deepInk = Color(0xFF213F37);
const _orange = Color(0xFFE36D3F);

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

  static const _designWidth = 273.0;
  static const _designHeight = 613.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthScale = constraints.maxWidth / _designWidth;
        final heightScale = constraints.maxHeight / _designHeight;
        final scale = math.min(widthScale, heightScale);
        final studentName = _displayName(widget.user);

        double x(double value) => value * widthScale;
        double y(double value) => value * heightScale;
        double s(double value) => value * scale;

        return SizedBox.expand(
          child: Stack(
            children: [
              const Positioned.fill(child: _HomeBackground()),
              Positioned(
                left: x(22),
                right: x(22),
                top: y(14),
                child: _Header(name: studentName, size: s(38)),
              ),
              Positioned(
                left: x(22),
                right: x(22),
                top: y(66),
                child: _TabContent(
                  activeTab: _activeTab,
                  heroCard: _TestHeroCard(
                    height: y(365),
                    mascotSize: s(172),
                    titleSize: s(24),
                    bodySize: s(11),
                    buttonHeight: s(35),
                  ),
                  user: widget.user,
                  onLogout: widget.onLogout,
                  contentHeight: y(365),
                  fontSize: s(14),
                ),
              ),
              if (_activeTab == 0) ...[
                Positioned(
                  left: x(22),
                  right: x(22),
                  top: y(450),
                  child: _AchievementsHeader(fontSize: s(14)),
                ),
                Positioned(
                  left: x(20),
                  right: x(20),
                  top: y(490),
                  child: _AchievementCard(
                    height: s(78),
                    iconSize: s(48),
                    titleSize: s(13),
                    bodySize: s(10),
                  ),
                ),
              ],
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BottomNavigation(
                  height: s(70),
                  iconSize: s(19),
                  labelSize: s(8),
                  activeIndex: _activeTab,
                  onTabSelected: (index) {
                    setState(() {
                      _activeTab = index;
                    });
                  },
                ),
              ),
            ],
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
    required this.activeTab,
    required this.heroCard,
    required this.user,
    required this.onLogout,
    required this.contentHeight,
    required this.fontSize,
  });

  final int activeTab;
  final Widget heroCard;
  final LoginUser? user;
  final VoidCallback onLogout;
  final double contentHeight;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (activeTab == 0) {
      return heroCard;
    }

    if (activeTab == 3) {
      return _AccountTab(
        user: user,
        onLogout: onLogout,
        height: contentHeight,
        fontSize: fontSize,
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE9F9ED),
            Color(0xFFEFFFF0),
            Color(0xFFE6FAF0),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size + 2,
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD6C1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: const Color(0xFF2A7D75),
                  size: size * 0.64,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 1,
                child: Container(
                  width: size * 0.22,
                  height: size * 0.22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16B881),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HỌC SINH',
                  style: TextStyle(
                    color: Color(0xFF9BAAA4),
                    fontFamily: 'Nunito',
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _teal,
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: _teal,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _TestHeroCard extends StatelessWidget {
  const _TestHeroCard({
    required this.height,
    required this.mascotSize,
    required this.titleSize,
    required this.bodySize,
    required this.buttonHeight,
  });

  final double height;
  final double mascotSize;
  final double titleSize;
  final double bodySize;
  final double buttonHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2DC8BE),
            Color(0xFFB2D1B7),
            Color(0xFFECE4CB),
          ],
          stops: [0, 0.55, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3AB8A7).withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          const Positioned(
            right: 34,
            top: 30,
            child: _HeroMathGlyph(),
          ),
          Positioned(
            left: 18,
            bottom: 28,
            child: Transform.rotate(
              angle: 0.18,
              child: const _HeroTriangleGhost(),
            ),
          ),
          Positioned(
            top: 44,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  'KIỂM TRA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Cùng AI kiểm tra khả năng toán học\nvượt trội riêng bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontFamily: 'Nunito',
                    fontSize: bodySize,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: height * 0.40,
            child: Image.asset(
              'assets/images/home_test_mascot.png',
              width: mascotSize,
              height: mascotSize,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 22,
            child: _HeroButton(height: buttonHeight),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.only(left: height * 0.44, right: height * 0.34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF8B64), _orange],
        ),
        boxShadow: [
          BoxShadow(
            color: _orange.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 6,
            offset: const Offset(0, 3),
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
              fontSize: height * 0.38,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          SizedBox(width: height * 0.22),
          Icon(Icons.rocket_launch_outlined,
              color: Colors.white, size: height * 0.52),
        ],
      ),
    );
  }
}

class _AchievementsHeader extends StatelessWidget {
  const _AchievementsHeader({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thành tích của bạn',
              style: TextStyle(
                color: _deepInk,
                fontFamily: 'Nunito',
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 34,
              height: 2,
              color: const Color(0xFFE9B68B),
            ),
          ],
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            'XEM TẤT CẢ',
            style: TextStyle(
              color: _teal,
              fontFamily: 'Nunito',
              fontSize: fontSize * 0.56,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.height,
    required this.iconSize,
    required this.titleSize,
    required this.bodySize,
  });

  final double height;
  final double iconSize;
  final double titleSize;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: const BoxDecoration(
              color: Color(0xFFE9F5F2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: _teal,
              size: iconSize * 0.48,
            ),
          ),
          const SizedBox(width: 14),
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
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Đã hoàn thành 12 bài tập hè',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.grayText,
                    fontFamily: 'Nunito',
                    fontSize: bodySize,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFDFF5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_right_rounded, color: _teal),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.height,
    required this.iconSize,
    required this.labelSize,
    required this.activeIndex,
    required this.onTabSelected,
  });

  final double height;
  final double iconSize;
  final double labelSize;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            top: 10,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: Icons.home_filled,
                  label: 'HOME',
                  iconSize: iconSize,
                  labelSize: labelSize,
                  active: activeIndex == 0,
                  onTap: () => onTabSelected(0),
                ),
                _NavItem(
                  icon: Icons.explore_outlined,
                  label: 'ÔN TẬP',
                  iconSize: iconSize,
                  labelSize: labelSize,
                  active: activeIndex == 1,
                  onTap: () => onTabSelected(1),
                ),
                _NavItem(
                  icon: Icons.map_outlined,
                  label: 'LỊCH SỬ',
                  iconSize: iconSize,
                  labelSize: labelSize,
                  active: activeIndex == 2,
                  onTap: () => onTabSelected(2),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'TÀI KHOẢN',
                  iconSize: iconSize,
                  labelSize: labelSize,
                  active: activeIndex == 3,
                  onTap: () => onTabSelected(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.labelSize,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final double iconSize;
  final double labelSize;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : const Color(0xFF8B9995);
    final itemHeight = math.max(44.0, iconSize + labelSize + 12);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: active ? 54 : 48,
        height: itemHeight,
        decoration: BoxDecoration(
          color: active ? _teal : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _teal.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: iconSize),
            const SizedBox(height: 2),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: color,
                    fontFamily: 'Nunito',
                    fontSize: labelSize,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
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

class _AccountTab extends StatelessWidget {
  const _AccountTab({
    required this.user,
    required this.onLogout,
    required this.height,
    required this.fontSize,
  });

  final LoginUser? user;
  final VoidCallback onLogout;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final userName = user?.name?.trim() ?? 'Minh Quân';
    final userEmail = user?.email?.trim() ?? '';
    final userPhone = user?.phone?.trim() ?? '';

    return SingleChildScrollView(
      child: SizedBox(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD6C1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(
                Icons.person_rounded,
                color: const Color(0xFF2A7D75),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              userName,
              style: TextStyle(
                color: _teal,
                fontFamily: 'Nunito',
                fontSize: fontSize + 2,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (userPhone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                userPhone,
                style: TextStyle(
                  color: const Color(0xFF8B9995),
                  fontFamily: 'Nunito',
                  fontSize: fontSize,
                ),
              ),
            ],
            if (userEmail.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                userEmail,
                style: TextStyle(
                  color: const Color(0xFF8B9995),
                  fontFamily: 'Nunito',
                  fontSize: fontSize,
                ),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'ĐĂNG XUẤT',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMathGlyph extends StatelessWidget {
  const _HeroMathGlyph();

  @override
  Widget build(BuildContext context) {
    return Text(
      'x²',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.10),
        fontFamily: 'Nunito',
        fontSize: 46,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    );
  }
}

class _HeroTriangleGhost extends StatelessWidget {
  const _HeroTriangleGhost();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: CustomPaint(
        painter: _TriangleOutlinePainter(
          color: Colors.white.withValues(alpha: 0.13),
        ),
      ),
    );
  }
}

class _TriangleOutlinePainter extends CustomPainter {
  const _TriangleOutlinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
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
    return oldDelegate.color != color;
  }
}
