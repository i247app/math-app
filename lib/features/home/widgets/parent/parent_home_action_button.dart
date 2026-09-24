import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentHomeActionButton extends StatelessWidget {
  const ParentHomeActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFFF45D2D),
    this.shadowColor = const Color(0xFFB8431A),
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(color: shadowColor, offset: const Offset(0, 5)),
          const BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 8),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: color,
        borderRadius: radius,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: radius,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 25),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
