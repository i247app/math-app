import 'package:flutter/material.dart';

class LoginCheckingDots extends StatefulWidget {
  const LoginCheckingDots({super.key});

  @override
  State<LoginCheckingDots> createState() => _LoginCheckingDotsState();
}

class _LoginCheckingDotsState extends State<LoginCheckingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('checking-phone-dots'),
      height: 64,
      child: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final progress = (controller.value + index * 0.22) % 1;
                final opacity = 0.35 + 0.65 * (1 - (progress - 0.5).abs() * 2);
                final lift = -7 * (1 - (progress - 0.5).abs() * 2);

                return Transform.translate(
                  offset: Offset(0, lift),
                  child: Container(
                    width: 9,
                    height: 9,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF798B8C).withValues(alpha: opacity),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
