import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _resultMint = Color(0xFFEBFAEC);
const _resultTeal = Color(0xFF006762);
const _resultInk = Color(0xFF253228);
const _resultMuted = Color(0xFF515F54);
const _resultPeach = Color(0xFFFFDCCA);
const _resultRust = Color(0xFFA03A0F);

class AssessmentResultScreen extends StatelessWidget {
  const AssessmentResultScreen({super.key});

  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _resultMint,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = math.min(constraints.maxWidth, 430.0);
              final height = constraints.maxHeight;
              final scale =
                  math.min(width / _designWidth, height / _designHeight);

              double s(double value) => value * scale;

              return Center(
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: _resultMint),
                        ),
                      ),
                      Positioned.fill(
                        top: s(72),
                        bottom: s(330),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            s(23),
                            s(14),
                            s(23),
                            s(28),
                          ),
                          child: Column(
                            children: [
                              _ScoreRing(scale: scale),
                              SizedBox(height: s(28)),
                              Text(
                                'Tuyệt vời!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _resultInk,
                                  fontFamily: 'Nunito',
                                  fontSize: 23 * scale,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  letterSpacing: 0,
                                ),
                              ),
                              SizedBox(height: s(12)),
                              Text(
                                'Bé đã hoàn thành xuất sắc thử thách này.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _resultMuted,
                                  fontFamily: 'Nunito',
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                  letterSpacing: 0,
                                ),
                              ),
                              SizedBox(height: s(19)),
                              _AiReviewCard(scale: scale),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: _ResultHeader(scale: scale),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: s(288),
                        child: _ResultBottomBar(scale: scale),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32 * scale)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 72 * scale,
          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
          decoration: BoxDecoration(
            color: _resultMint.withValues(alpha: 0.84),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(32 * scale),
            ),
          ),
          child: Row(
            children: [
              _HeaderIconButton(
                icon: Icons.close_rounded,
                scale: scale,
                onTap: () => _exitToHome(context),
              ),
              Expanded(
                child: Text(
                  'Kết quả thử thách',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _resultTeal,
                    fontFamily: 'Nunito',
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              _HeaderIconButton(
                icon: Icons.help_outline_rounded,
                scale: scale,
                onTap: HapticFeedback.selectionClick,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38 * scale,
          height: 38 * scale,
          child: Icon(
            icon,
            color: _resultTeal,
            size: 23 * scale,
          ),
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150 * scale,
      height: 150 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _resultTeal, width: 8.5 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '9/10',
            style: TextStyle(
              color: _resultTeal,
              fontFamily: 'Nunito',
              fontSize: 39 * scale,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 7 * scale),
          Text(
            'ĐIỂM SỐ',
            style: TextStyle(
              color: _resultMuted,
              fontFamily: 'Nunito',
              fontSize: 10 * scale,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiReviewCard extends StatelessWidget {
  const _AiReviewCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        17 * scale,
        18 * scale,
        17 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 47 * scale,
            height: 47 * scale,
            decoration: BoxDecoration(
              color: _resultTeal.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/home_test_mascot.png',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Numi AI nhận xét',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _resultInk,
                          fontFamily: 'Nunito',
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: _resultTeal,
                      size: 15 * scale,
                    ),
                  ],
                ),
                SizedBox(height: 9 * scale),
                Text(
                  '"Bé làm rất tốt phần phép cộng, hãy tiếp tục phát huy nhé! Chúng ta chỉ cần luyện tập thêm một chút ở các phép trừ có nhớ thôi."',
                  style: TextStyle(
                    color: _resultMuted,
                    fontFamily: 'Nunito',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    letterSpacing: 0,
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

class _ResultBottomBar extends StatelessWidget {
  const _ResultBottomBar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 78 * scale,
          padding: EdgeInsets.fromLTRB(
            23 * scale,
            16 * scale,
            23 * scale,
            14 * scale,
          ),
          decoration: BoxDecoration(
            color: _resultMint.withValues(alpha: 0.90),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFCDE2CF).withValues(alpha: 0.34),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _ResultActionButton(
                  label: 'THOÁT',
                  icon: Icons.logout_rounded,
                  background: _resultPeach,
                  foreground: _resultRust,
                  scale: scale,
                  onTap: () => _exitToHome(context),
                ),
              ),
              SizedBox(width: 20 * scale),
              Expanded(
                child: _ResultActionButton(
                  label: 'TEST AGAIN',
                  icon: Icons.arrow_forward_rounded,
                  foreground: const Color(0xFFBEFFF9),
                  scale: scale,
                  onTap: HapticFeedback.selectionClick,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_resultTeal, Color(0xFF73F1E7)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultActionButton extends StatelessWidget {
  const _ResultActionButton({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.scale,
    required this.onTap,
    this.background,
    this.gradient,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final double scale;
  final VoidCallback onTap;
  final Color? background;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 52 * scale,
          decoration: BoxDecoration(
            color: background,
            gradient: gradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: gradient == null
                ? null
                : [
                    BoxShadow(
                      color: _resultTeal.withValues(alpha: 0.20),
                      blurRadius: 8 * scale,
                      offset: Offset(0, 5 * scale),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 16 * scale),
              SizedBox(width: 9 * scale),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: foreground,
                    fontFamily: 'Nunito',
                    fontSize: 12.5 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _exitToHome(BuildContext context) {
  HapticFeedback.mediumImpact();
  Navigator.of(context).popUntil((route) => route.isFirst);
}
