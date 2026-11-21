import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class PlacementActionButton extends StatelessWidget {
  const PlacementActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
    this.borderRadius = 14,
    this.iconAtEnd = false,
    this.gradient,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;
  final double borderRadius;
  final bool iconAtEnd;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foregroundColor = outlined
        ? color
        : (isDark ? colors.onPrimaryAction : colors.onBrand);
    final radius = BorderRadius.circular(borderRadius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: outlined
            ? null
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            height: 50,
            decoration: BoxDecoration(
              color: outlined
                  ? (isDark ? colors.surface : Colors.white)
                  : color,
              gradient: outlined ? null : gradient,
              borderRadius: radius,
              border: outlined ? Border.all(color: color, width: 1.5) : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!iconAtEnd) ...[
                      Icon(icon, color: foregroundColor, size: 19),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      style: GoogleFonts.andika(
                        color: foregroundColor,
                        fontSize: FontSize.normal,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    if (iconAtEnd) ...[
                      const SizedBox(width: 8),
                      Icon(icon, color: foregroundColor, size: 19),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
