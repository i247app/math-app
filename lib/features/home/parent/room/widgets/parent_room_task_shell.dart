import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:numi_flutter/core/theme/app_theme_colors.dart';

class ParentRoomTaskShell extends StatelessWidget {
  const ParentRoomTaskShell({
    required this.accent,
    required this.child,
    required this.onTap,
    required this.compact,
    this.leading,
  });

  final Color accent;
  final Widget child;
  final Widget? leading;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Material(
      color: colors.elevatedSurface,
      elevation: compact ? 2.5 : 1.5,
      shadowColor: colors.shadow.withValues(alpha: compact ? 0.95 : 0.70),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: compact ? 101 : 103),
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(14),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 13),
                    ],
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}