import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/theme/font_size.dart';

/// A shared section header with a title on the left and an optional action
/// button on the right.
///
/// Replaces both [_StudentSectionHeader] and [_TeacherHomeSectionHeader].
/// Callers can fully customise the [titleStyle] and [actionStyle] to match
/// role-specific design tokens.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.scale = 1.0,
    this.titleStyle,
    this.actionStyle,
    this.useHaptic = true,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double scale;
  final TextStyle? titleStyle;
  final TextStyle? actionStyle;
  final bool useHaptic;

  @override
  Widget build(BuildContext context) {
    final effectiveTitleStyle = titleStyle ??
        TextStyle(
          color: const Color(0xFF001741),
          fontSize: FontSize.normal * scale,
          fontWeight: FontWeight.w900,
          height: 1.25,
          letterSpacing: 0,
        );

    final effectiveActionStyle = actionStyle ??
        TextStyle(
          color: const Color(0xFFBC3B14),
          fontSize: FontSize.small * scale,
          fontWeight: FontWeight.w900,
          decoration: TextDecoration.underline,
          height: 1.2,
          letterSpacing: 0,
        );

    final label = actionLabel;
    final action = label != null
        ? Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: effectiveActionStyle,
          )
        : null;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: effectiveTitleStyle,
          ),
        ),
        if (action != null) ...[
          SizedBox(width: 12 * scale),
          if (onAction == null)
            action
          else
            InkWell(
              onTap: () {
                if (useHaptic) HapticFeedback.selectionClick();
                onAction!();
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4 * scale),
                child: action,
              ),
            ),
        ],
      ],
    );
  }
}
