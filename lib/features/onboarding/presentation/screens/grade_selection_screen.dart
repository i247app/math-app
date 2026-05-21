import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import 'assessment_screen.dart';

const _gradeMint = Color(0xFFEBFAEC);
const _gradeTeal = Color(0xFF006762);
const _gradeInk = Color(0xFF253228);
const _gradePeach = Color(0xFFFFDCCA);
const _gradeRust = Color(0xFFA03A0F);

class GradeSelectionScreen extends StatelessWidget {
  const GradeSelectionScreen({super.key});

  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _gradeMint,
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
                      const Positioned.fill(child: _GradeBackground()),
                      Positioned.fill(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            s(38),
                            s(132),
                            s(38),
                            s(128),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Bé đang học lớp mấy\nnhỉ?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _gradeInk,
                                  fontFamily: 'Nunito',
                                  fontSize: s(31),
                                  fontWeight: FontWeight.w900,
                                  height: 1.08,
                                  letterSpacing: 0,
                                ),
                              ),
                              SizedBox(height: s(26)),
                              _GradeGrid(scale: scale),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: _GradeHeader(scale: scale),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _GradeBottomBar(
                          scale: scale,
                          onSkip: () {
                            HapticFeedback.mediumImpact();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (_) => const AiAssessmentScreen(),
                              ),
                            );
                          },
                          onContinue: () {
                            HapticFeedback.selectionClick();
                          },
                        ),
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

class _GradeBackground extends StatelessWidget {
  const _GradeBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_gradeMint, Color(0xFFD8EBD8), _gradeMint],
          stops: [0, 0.80, 1],
        ),
      ),
    );
  }
}

class _GradeHeader extends StatelessWidget {
  const _GradeHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 70 * scale,
          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
          color: _gradeMint.withValues(alpha: 0.78),
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).maybePop();
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              color: _gradeTeal,
              size: 28 * scale,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(
              width: 42 * scale,
              height: 42 * scale,
            ),
            tooltip: 'Quay lại',
          ),
        ),
      ),
    );
  }
}

class _GradeGrid extends StatelessWidget {
  const _GradeGrid({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    const items = [
      _GradeOption(null, 'Mẫu giáo', kindergarten: true),
      _GradeOption('1', 'Lớp 1'),
      _GradeOption('2', 'Lớp 2'),
      _GradeOption('3', 'Lớp 3'),
      _GradeOption('4', 'Lớp 4'),
      _GradeOption('5', 'Lớp 5'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12 * scale,
        crossAxisSpacing: 12 * scale,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        return _GradeCard(option: items[index], scale: scale);
      },
    );
  }
}

class _GradeCard extends StatelessWidget {
  const _GradeCard({
    required this.option,
    required this.scale,
  });

  final _GradeOption option;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: option.label,
      enabled: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20 * scale,
          20 * scale,
          20 * scale,
          17 * scale,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(28 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GradeBadge(option: option, scale: scale),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                option.label,
                maxLines: 1,
                style: TextStyle(
                  color: _gradeInk,
                  fontFamily: 'Nunito',
                  fontSize: 17 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({
    required this.option,
    required this.scale,
  });

  final _GradeOption option;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 35 * scale;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: option.kindergarten ? _gradePeach : AppColors.aquaMist,
        shape: BoxShape.circle,
      ),
      child: option.kindergarten
          ? Icon(
              Icons.face_retouching_natural_rounded,
              color: _gradeRust,
              size: 20 * scale,
            )
          : Text(
              option.number!,
              style: TextStyle(
                color: _gradeTeal,
                fontFamily: 'Nunito',
                fontSize: 17 * scale,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0,
              ),
            ),
    );
  }
}

class _GradeBottomBar extends StatelessWidget {
  const _GradeBottomBar({
    required this.scale,
    required this.onSkip,
    required this.onContinue,
  });

  final double scale;
  final VoidCallback onSkip;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 72 * scale,
          padding: EdgeInsets.fromLTRB(
            24 * scale,
            10 * scale,
            24 * scale,
            10 * scale,
          ),
          decoration: BoxDecoration(
            color: _gradeMint.withValues(alpha: 0.90),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 22 * scale,
                offset: Offset(0, -8 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 9,
                child: _PillActionButton(
                  label: 'BỎ QUA',
                  background: _gradePeach,
                  foreground: _gradeRust,
                  scale: scale,
                  onPressed: onSkip,
                ),
              ),
              SizedBox(width: 20 * scale),
              Expanded(
                flex: 10,
                child: _PillActionButton(
                  label: 'TIẾP TỤC',
                  icon: Icons.arrow_forward_rounded,
                  background: _gradeTeal,
                  foreground: Colors.white,
                  gradient: const LinearGradient(
                    colors: [_gradeTeal, Color(0xFF55E0D6)],
                  ),
                  scale: scale,
                  onPressed: onContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillActionButton extends StatelessWidget {
  const _PillActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.scale,
    required this.onPressed,
    this.icon,
    this.gradient,
  });

  final String label;
  final Color background;
  final Color foreground;
  final double scale;
  final VoidCallback onPressed;
  final IconData? icon;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44 * scale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gradient == null ? background : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: gradient == null
              ? null
              : [
                  BoxShadow(
                    color: _gradeTeal.withValues(alpha: 0.24),
                    blurRadius: 12 * scale,
                    offset: Offset(0, 8 * scale),
                  ),
                ],
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foreground,
            shape: const StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0.8,
                  ),
                ),
                if (icon != null) ...[
                  SizedBox(width: 8 * scale),
                  Icon(icon, size: 18 * scale),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradeOption {
  const _GradeOption(
    this.number,
    this.label, {
    this.kindergarten = false,
  });

  final String? number;
  final String label;
  final bool kindergarten;
}
