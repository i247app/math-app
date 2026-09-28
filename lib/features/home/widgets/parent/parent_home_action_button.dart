import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentHomeActionButton extends StatelessWidget {
  const ParentHomeActionButton({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.onTap,
    required this.colors,
    required this.accentColor,
  });

  final String label;
  final String iconAsset;
  final VoidCallback onTap;
  final List<Color> colors;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = ((constraints.maxWidth - 56) / 6.1).clamp(14.0, 18.0);
        final textScale =
            MediaQuery.textScalerOf(context).scale(fontSize) / fontSize;
        final hasExplicitLines = label.contains('\n');
        final labelStyle = GoogleFonts.nunito(
          color: const Color(0xFFFFFDF5),
          fontSize: fontSize,
          height: 1.15,
          fontWeight: FontWeight.w900,
        );
        final icon = Image.asset(
          iconAsset,
          width: 58,
          height: 58,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        );
        final arrow = DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFDF5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.chevron_right_rounded,
            color: colors.first,
            size: 24,
          ),
        );

        return Semantics(
          button: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: colors.last.withValues(alpha: 0.22),
                  offset: const Offset(0, 6),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Material(
              color: colors.first,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -24,
                      right: -18,
                      child: IgnorePointer(
                        child: Ink(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -44,
                      right: -16,
                      child: IgnorePointer(
                        child: Ink(
                          width: 90,
                          height: 66,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(45),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTap();
                      },
                      child: SizedBox(
                        height:
                            126 +
                            (textScale - 1).clamp(0, double.infinity) * 48,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 12, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasExplicitLines)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [icon, arrow],
                                )
                              else
                                icon,
                              const Spacer(),
                              if (hasExplicitLines)
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    label,
                                    maxLines: 2,
                                    softWrap: false,
                                    style: labelStyle,
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        label,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: labelStyle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    arrow,
                                  ],
                                ),
                            ],
                          ),
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
