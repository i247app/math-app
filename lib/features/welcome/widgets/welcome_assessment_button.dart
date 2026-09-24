import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeAssessmentButton extends StatelessWidget {
  const WelcomeAssessmentButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(999);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: const [
                BoxShadow(color: Color(0xFFB8431A), offset: Offset(0, 5)),
                BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(0, 8),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Material(
              color: const Color(0xFFF45D2D),
              borderRadius: radius,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onPressed();
                },
                borderRadius: radius,
                child: SizedBox(
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'TEST YOUR SKILL',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF855B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
