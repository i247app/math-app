import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.child,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  final Widget child;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final horizontalPadding = width < 370 ? 24.0 : 32.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: double.infinity,
          height: constraints.maxHeight,
          child: SingleChildScrollView(
            keyboardDismissBehavior: keyboardDismissBehavior,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.navy.withValues(alpha: enabled ? 1 : 0.55),
              AppColors.softBlue.withValues(alpha: enabled ? 1 : 0.55),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 9),
                  ),
                ]
              : null,
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 42,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.88),
      elevation: 2,
      shadowColor: AppColors.greenShadow,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: AppColors.teal, size: size * 0.52),
        ),
      ),
    );
  }
}

class ProgressDots extends StatelessWidget {
  const ProgressDots({
    super.key,
    required this.activeIndex,
    this.count = 4,
  });

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: List.generate(count, (index) {
          final active = index == activeIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: active ? 20 : 7,
            height: 7,
            margin: EdgeInsets.only(left: index == 0 ? 0 : 7),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.teal
                  : Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(999),
              border: active
                  ? null
                  : Border.all(color: AppColors.teal.withValues(alpha: 0.16)),
            ),
          );
        }),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
    this.message = 'Đang tải...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BrandMark(compact: true),
            const SizedBox(height: 28),
            const SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 36.0 : 50.0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 12,
        compact ? 7 : 8,
        compact ? 13 : 16,
        compact ? 7 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScanCubeIcon(size: iconSize),
          const SizedBox(width: 8),
          CalculatorIcon(size: iconSize - 5),
          const SizedBox(width: 8),
          Text(
            'NUMI',
            style: TextStyle(
              color: AppColors.teal,
              fontSize: compact ? 29 : 39,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorIcon extends StatelessWidget {
  const CalculatorIcon({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          height: 1,
          fontWeight: FontWeight.w900,
        ),
        child: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(size * 0.18),
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            Text('+', textAlign: TextAlign.center),
            Text('×', textAlign: TextAlign.center),
            Text('−', textAlign: TextAlign.center),
            Text('=', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ScanCubeIcon extends StatelessWidget {
  const ScanCubeIcon({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.view_in_ar_rounded,
            color: AppColors.softBlue,
            size: size * 0.58,
          ),
          CustomPaint(size: Size.square(size), painter: ScanCornersPainter()),
        ],
      ),
    );
  }
}

class PlusBadge extends StatelessWidget {
  const PlusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.softBlue, width: 5),
      ),
      child: const Text(
        '+',
        style: TextStyle(
          color: AppColors.softBlue,
          fontSize: 38,
          height: 0.9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class RobotCard extends StatelessWidget {
  const RobotCard({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.coral, AppColors.coralLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: size * 0.14,
            bottom: -size * 0.1,
            child: CustomPaint(
              size: Size(size * 0.18, size * 0.1),
              painter: BookmarkPainter(),
            ),
          ),
          Positioned(
            left: -size * 0.18,
            bottom: size * 0.22,
            child: Transform.rotate(
              angle: -0.24,
              child: const MathBubble(
                text: '2 × 2 = 4',
                foreground: AppColors.mathInk,
                background: AppColors.peach,
              ),
            ),
          ),
          Positioned(
            right: -size * 0.12,
            top: size * 0.18,
            child: Transform.rotate(
              angle: 0.12,
              child: const MathBubble(
                text: '5 + 3 = 8',
                foreground: AppColors.teal,
                background: Colors.white,
              ),
            ),
          ),
          Center(
            child: Transform.translate(
              offset: Offset(0, size * 0.04),
              child: Robot(width: size * 0.56),
            ),
          ),
        ],
      ),
    );
  }
}

class NumiMascot extends StatelessWidget {
  const NumiMascot({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.coral, AppColors.coralLight],
              ),
              borderRadius: BorderRadius.circular(size * 0.18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
          Positioned(
            left: -12,
            top: size * 0.28,
            child: const MathBubble(text: '2 + 3 = 5'),
          ),
          Positioned(
            right: -10,
            top: size * 0.16,
            child: const MathBubble(text: '4 x 2 = 8'),
          ),
          Container(
            width: size * 0.54,
            height: size * 0.66,
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(size * 0.18),
              border: Border.all(color: AppColors.teal, width: 4),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: size * 0.16,
                  left: size * 0.13,
                  child: const RobotEye(),
                ),
                Positioned(
                  top: size * 0.16,
                  right: size * 0.13,
                  child: const RobotEye(),
                ),
                Positioned(
                  bottom: size * 0.18,
                  child: Container(
                    width: size * 0.18,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
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

class MathBubble extends StatelessWidget {
  const MathBubble({
    super.key,
    required this.text,
    this.foreground = AppColors.teal,
    this.background = Colors.white,
  });

  final String text;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class RobotEye extends StatelessWidget {
  const RobotEye({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.coral,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.deepTeal, width: 3),
      ),
      child: Center(
        child: Container(
          width: 25,
          height: 25,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 0.74,
              colors: [Colors.white, Colors.black],
              stops: [0.14, 0.15],
            ),
          ),
        ),
      ),
    );
  }
}

class Robot extends StatelessWidget {
  const Robot({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final w = width;

    return SizedBox(
      width: w,
      height: w * 1.28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: w * 0.06,
            child: Container(
              width: w * 0.84,
              height: w * 0.13,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            bottom: w * 0.12,
            child: Container(
              width: w * 0.6,
              height: w * 0.42,
              decoration: robotDecoration(w * 0.16),
              child: Center(
                child: Container(
                  width: w * 0.32,
                  height: w * 0.1,
                  decoration: BoxDecoration(
                    color: AppColors.panelDark,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.deepTeal, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      5,
                      (_) => Container(width: 4, color: AppColors.coral),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: w * 0.02,
            bottom: w * 0.02,
            child: const RobotArm(left: true),
          ),
          Positioned(
            right: w * 0.02,
            bottom: w * 0.02,
            child: const RobotArm(left: false),
          ),
          Positioned(
            top: w * 0.08,
            child: Container(
              width: w * 0.82,
              height: w * 0.66,
              decoration: robotDecoration(w * 0.25),
            ),
          ),
          Positioned(top: w * 0.28, left: w * 0.22, child: const RobotEye()),
          Positioned(top: w * 0.28, right: w * 0.22, child: const RobotEye()),
          Positioned(
            top: w * 0.5,
            left: w * 0.32,
            child: Container(
              width: w * 0.11,
              height: w * 0.045,
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            top: w * 0.5,
            child: CustomPaint(
              size: Size(w * 0.18, w * 0.09),
              painter: SmilePainter(),
            ),
          ),
          Positioned(left: 0, top: w * 0.32, child: const RobotEar()),
          Positioned(right: 0, top: w * 0.32, child: const RobotEar()),
        ],
      ),
    );
  }

  BoxDecoration robotDecoration(double radius) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.robotGlow, AppColors.robotDark],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.teal.withValues(alpha: 0.45),
        width: 2,
      ),
    );
  }
}

class RobotArm extends StatelessWidget {
  const RobotArm({super.key, required this.left});

  final bool left;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: left ? -0.26 : 0.26,
      child: Column(
        children: [
          Container(
            width: 20,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.robotLight, AppColors.robotDark],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.deepTeal.withValues(alpha: 0.55),
                width: 2,
              ),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.robotLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.deepTeal.withValues(alpha: 0.55),
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RobotEar extends StatelessWidget {
  const RobotEar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 45,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.robotLight, AppColors.robotDark],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.deepTeal.withValues(alpha: 0.55),
          width: 2,
        ),
      ),
    );
  }
}

class VietnamFlag extends StatelessWidget {
  const VietnamFlag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.vietnamRed,
        borderRadius: BorderRadius.circular(2),
      ),
      child: const Icon(Icons.star, color: Colors.yellow, size: 11),
    );
  }
}

class BookmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.bookmark;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height * 0.72)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.deepTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(size.width / 2, size.height, size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.softBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final corner = size.width * 0.34;
    final inset = size.width * 0.05;

    void drawCorner(Offset a, Offset b, Offset c) {
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy);
      canvas.drawPath(path, paint);
    }

    drawCorner(
      Offset(inset + corner, inset),
      Offset(inset, inset),
      Offset(inset, inset + corner),
    );
    drawCorner(
      Offset(size.width - inset - corner, inset),
      Offset(size.width - inset, inset),
      Offset(size.width - inset, inset + corner),
    );
    drawCorner(
      Offset(inset, size.height - inset - corner),
      Offset(inset, size.height - inset),
      Offset(inset + corner, size.height - inset),
    );
    drawCorner(
      Offset(size.width - inset, size.height - inset - corner),
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset - corner, size.height - inset),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
