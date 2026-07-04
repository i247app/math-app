import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/quiz/widgets/grade_selection/grade_selection_style.dart';
import 'package:numi_flutter/features/quiz/widgets/grade_selection/pill_action_button.dart';

class GradeBottomBar extends StatelessWidget {
  const GradeBottomBar({
    super.key,
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
            color: GradeSelectionStyle.mint.withValues(alpha: 0.90),
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
                child: PillActionButton(
                  label: context.getText(AppKeys.skipUpper),
                  background: GradeSelectionStyle.peach,
                  foreground: GradeSelectionStyle.rust,
                  scale: scale,
                  onPressed: onSkip,
                ),
              ),
              SizedBox(width: 20 * scale),
              Expanded(
                flex: 10,
                child: PillActionButton(
                  label: context.getText(AppKeys.continueUpper),
                  icon: Icons.arrow_forward_rounded,
                  background: GradeSelectionStyle.teal,
                  foreground: Colors.white,
                  gradient: const LinearGradient(
                    colors: [GradeSelectionStyle.teal, Color(0xFF55E0D6)],
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
